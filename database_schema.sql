-- ============================================================================
-- FindIt UNILA - Skema Database PostgreSQL / Supabase + Row Level Security
-- ============================================================================
-- Jalankan script ini di Supabase SQL Editor.
-- Jangan pernah menyertakan atau memakai service_role key di aplikasi client.
-- ============================================================================

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- 1. Tabel Profil Pengguna (terhubung dengan auth.users)
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  email text not null unique,
  faculty text not null,
  npm text not null default '',
  phone text not null default '',
  smart_match_notifications boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. Tabel Laporan Barang Hilang & Temuan
-- ----------------------------------------------------------------------------
create table if not exists public.item_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  category text not null,
  report_type text not null check (report_type in ('lost', 'found')),
  status text not null default 'active' check (status in ('active', 'claimed', 'resolved')),
  color_name text not null,
  description text not null,
  faculty text not null,
  location text not null,
  incident_date date not null,
  photo_label text,
  photo_url text,
  reporter_name text not null,
  reporter_faculty text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_item_reports_created_at
  on public.item_reports (created_at desc);

create index if not exists idx_item_reports_user_id
  on public.item_reports (user_id);

create index if not exists idx_item_reports_filter
  on public.item_reports (report_type, category, faculty);

-- ----------------------------------------------------------------------------
-- 3. Tabel Pengajuan Klaim & Konfirmasi Penemuan
-- ----------------------------------------------------------------------------
create table if not exists public.claim_requests (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.item_reports (id) on delete cascade,
  claimant_id uuid not null references public.profiles (id) on delete cascade,
  claimant_name text not null,
  verification_note text not null,
  contact_info text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint unique_claim_per_user unique (item_id, claimant_id)
);

create index if not exists idx_claim_requests_claimant_id
  on public.claim_requests (claimant_id, created_at desc);

create index if not exists idx_claim_requests_item_id
  on public.claim_requests (item_id);

-- ----------------------------------------------------------------------------
-- 4. Fungsi & Trigger Otomatis
-- ----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists trg_item_reports_updated_at on public.item_reports;
create trigger trg_item_reports_updated_at
  before update on public.item_reports
  for each row execute function public.set_updated_at();

drop trigger if exists trg_claim_requests_updated_at on public.claim_requests;
create trigger trg_claim_requests_updated_at
  before update on public.claim_requests
  for each row execute function public.set_updated_at();

-- Membuat baris profil otomatis ketika user baru mendaftar via Supabase Auth
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, faculty, npm, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(coalesce(new.email, 'mahasiswa'), '@', 1)),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'faculty', 'Fakultas Teknik (FT)'),
    coalesce(new.raw_user_meta_data ->> 'npm', ''),
    coalesce(new.raw_user_meta_data ->> 'phone', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Otomatis ubah status laporan menjadi 'claimed' saat klaim baru diajukan
create or replace function public.mark_item_claimed_on_request()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.item_reports
  set status = 'claimed'
  where id = new.item_id
    and status = 'active';
  return new;
end;
$$;

drop trigger if exists trg_mark_item_claimed on public.claim_requests;
create trigger trg_mark_item_claimed
  after insert on public.claim_requests
  for each row execute function public.mark_item_claimed_on_request();

-- ============================================================================
-- 5. Row Level Security (RLS) & Kebijakan Akses
-- ============================================================================

alter table public.profiles enable row level security;
alter table public.item_reports enable row level security;
alter table public.claim_requests enable row level security;

-- ---- Policies untuk public.profiles ----
drop policy if exists "Pengguna dapat melihat profil sendiri" on public.profiles;
create policy "Pengguna dapat melihat profil sendiri"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "Pengguna dapat membuat profil sendiri" on public.profiles;
create policy "Pengguna dapat membuat profil sendiri"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Pengguna dapat memperbarui profil sendiri" on public.profiles;
create policy "Pengguna dapat memperbarui profil sendiri"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---- Policies untuk public.item_reports ----
drop policy if exists "Semua pengguna dapat melihat daftar laporan barang" on public.item_reports;
create policy "Semua pengguna dapat melihat daftar laporan barang"
  on public.item_reports
  for select
  using (true);

drop policy if exists "Pengguna login dapat membuat laporan barang" on public.item_reports;
create policy "Pengguna login dapat membuat laporan barang"
  on public.item_reports
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Pembuat laporan dapat memperbarui laporannya" on public.item_reports;
create policy "Pembuat laporan dapat memperbarui laporannya"
  on public.item_reports
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Pembuat laporan dapat menghapus laporannya" on public.item_reports;
create policy "Pembuat laporan dapat menghapus laporannya"
  on public.item_reports
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- ---- Policies untuk public.claim_requests ----
drop policy if exists "Pengklaim atau pemilik laporan dapat melihat klaim" on public.claim_requests;
create policy "Pengklaim atau pemilik laporan dapat melihat klaim"
  on public.claim_requests
  for select
  to authenticated
  using (
    auth.uid() = claimant_id
    or exists (
      select 1
      from public.item_reports r
      where r.id = item_id
        and r.user_id = auth.uid()
    )
  );

drop policy if exists "Pengguna dapat mengajukan klaim untuk barang orang lain" on public.claim_requests;
create policy "Pengguna dapat mengajukan klaim untuk barang orang lain"
  on public.claim_requests
  for insert
  to authenticated
  with check (
    auth.uid() = claimant_id
    and exists (
      select 1
      from public.item_reports r
      where r.id = item_id
        and r.user_id <> auth.uid()
        and r.status <> 'resolved'
    )
  );

drop policy if exists "Pemilik laporan dapat memperbarui status klaim" on public.claim_requests;
create policy "Pemilik laporan dapat memperbarui status klaim"
  on public.claim_requests
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.item_reports r
      where r.id = item_id
        and r.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1
      from public.item_reports r
      where r.id = item_id
        and r.user_id = auth.uid()
    )
  );

drop policy if exists "Pengklaim dapat membatalkan klaim yang masih pending" on public.claim_requests;
create policy "Pengklaim dapat membatalkan klaim yang masih pending"
  on public.claim_requests
  for delete
  to authenticated
  using (
    auth.uid() = claimant_id
    and status = 'pending'
  );
