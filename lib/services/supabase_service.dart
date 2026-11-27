import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../models/claim_request.dart';
import '../models/item_report.dart';
import '../models/user_profile.dart';

/// Layanan penghubung aplikasi FindIt UNILA dengan Supabase Auth & Database.
/// Hanya menggunakan SUPABASE_URL dan SUPABASE_ANON_KEY dari --dart-define.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  bool get isActive => _isInitialized && SupabaseConfig.isConfigured;

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentAuthUser => isActive ? _client.auth.currentUser : null;

  Session? get currentSession => isActive ? _client.auth.currentSession : null;

  Stream<AuthState> get onAuthStateChange => isActive
      ? _client.auth.onAuthStateChange
      : const Stream<AuthState>.empty();

  /// Menginisialisasi Supabase apabila --dart-define SUPABASE_URL dan SUPABASE_ANON_KEY tersedia.
  Future<void> initialize() async {
    if (_isInitialized || !SupabaseConfig.isConfigured) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: true,
      ),
    );
    _isInitialized = true;
  }

  /// Memastikan profil tersedia di tabel `profiles` tanpa menimpa data pengguna yang sudah ada.
  Future<UserProfile> ensureProfileForUser(
    User user, {
    String? fallbackEmail,
  }) async {
    final existing = await fetchProfile(user.id);
    if (existing != null) return existing;

    final effectiveEmail = user.email ?? fallbackEmail?.trim() ?? '';
    final fallback = UserProfile(
      id: user.id,
      fullName: (user.userMetadata?['full_name'] as String?) ??
          (effectiveEmail.isNotEmpty
              ? effectiveEmail.split('@').first
              : 'Mahasiswa UNILA'),
      email: effectiveEmail,
      faculty: (user.userMetadata?['faculty'] as String?) ??
          'Fakultas Teknik (FT)',
      npm: (user.userMetadata?['npm'] as String?) ?? '',
      phone: (user.userMetadata?['phone'] as String?) ?? '',
    );
    await upsertProfile(fallback);
    return fallback;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Gagal masuk ke akun Supabase.');
    }

    return ensureProfileForUser(user, fallbackEmail: email);
  }

  /// Mendaftarkan akun baru dengan `emailRedirectTo` ke deep link aplikasi Android.
  /// Mengembalikan [UserProfile] jika sesi langsung aktif, atau `null` bila
  /// Supabase mewajibkan verifikasi email terlebih dahulu.
  Future<UserProfile?> signUp({
    required String fullName,
    required String email,
    required String faculty,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: SupabaseConfig.authCallbackUrl,
      data: {
        'full_name': fullName.trim(),
        'faculty': faculty,
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Registrasi gagal diproses.');
    }

    if (response.session == null) {
      return null;
    }

    return ensureProfileForUser(user, fallbackEmail: email);
  }

  /// Mengirim ulang email konfirmasi pendaftaran dengan `emailRedirectTo` deep link Android.
  Future<void> resendConfirmationEmail(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
      emailRedirectTo: SupabaseConfig.authCallbackUrl,
    );
  }

  Future<void> signOut() async {
    if (!isActive) return;
    await _client.auth.signOut();
  }

  /// Mengubah pesan error Supabase Auth menjadi pesan Bahasa Indonesia yang jelas.
  String formatAuthError(Object error) {
    if (error is AuthException) {
      final raw = error.message.toLowerCase();
      final code = (error.code ?? '').toLowerCase();
      final status = (error.statusCode ?? '').toLowerCase();

      if (raw.contains('otp_expired') ||
          code == 'otp_expired' ||
          status == 'otp_expired' ||
          raw.contains('expired') ||
          raw.contains('invalid or has expired')) {
        return 'Link konfirmasi email tidak valid atau sudah kedaluwarsa. Silakan kirim ulang email konfirmasi.';
      }
      if (raw.contains('email not confirmed')) {
        return 'Email belum diverifikasi. Periksa kotak masuk/spam Anda atau kirim ulang email konfirmasi.';
      }
      if (raw.contains('invalid login credentials')) {
        return 'Email atau password salah. Pastikan akun sudah terdaftar dan email sudah diverifikasi.';
      }
      if (raw.contains('user already registered') ||
          raw.contains('already registered')) {
        return 'Email sudah terdaftar. Silakan masuk atau kirim ulang email konfirmasi jika belum terverifikasi.';
      }
      if (raw.contains('rate limit') ||
          raw.contains('security purposes') ||
          raw.contains('too many requests')) {
        return 'Terlalu banyak permintaan. Mohon tunggu sebentar sebelum mengirim ulang email.';
      }
      if (raw.contains('code verifier') || raw.contains('pkce')) {
        return 'Sesi verifikasi PKCE tidak ditemukan di perangkat ini. Silakan kirim ulang email konfirmasi dari aplikasi.';
      }
      return error.message;
    }
    return 'Terjadi kesalahan autentikasi: $error';
  }

  Future<UserProfile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return UserProfile.fromMap(row);
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await _client.from('profiles').upsert(profile.toMap());
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required String fullName,
    required String faculty,
    required String phone,
  }) async {
    final updated = await _client
        .from('profiles')
        .update({
          'full_name': fullName.trim(),
          'faculty': faculty,
          'phone': phone.trim(),
        })
        .eq('id', userId)
        .select()
        .single();
    return UserProfile.fromMap(updated);
  }

  Future<void> updateSmartMatchNotifications({
    required String userId,
    required bool enabled,
  }) async {
    await _client
        .from('profiles')
        .update({'smart_match_notifications': enabled})
        .eq('id', userId);
  }

  Future<List<ItemReport>> fetchReports({String? currentUserId}) async {
    final rows = await _client
        .from('item_reports')
        .select()
        .order('created_at', ascending: false);

    return rows
        .map<ItemReport>(
          (row) => ItemReport.fromMap(row, currentUserId: currentUserId),
        )
        .toList();
  }

  Future<ItemReport> createReport({
    required ItemReport report,
    required String userId,
  }) async {
    final inserted = await _client
        .from('item_reports')
        .insert(report.toInsertMap(userId))
        .select()
        .single();

    return ItemReport.fromMap(inserted, currentUserId: userId);
  }

  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    await _client
        .from('item_reports')
        .update({'status': status.name})
        .eq('id', reportId);
  }

  Future<List<ClaimRequest>> fetchUserClaims(String userId) async {
    final rows = await _client
        .from('claim_requests')
        .select(
          'id, item_id, claimant_name, verification_note, contact_info, status, created_at, item_reports(title, report_type, category, location, faculty)',
        )
        .eq('claimant_id', userId)
        .order('created_at', ascending: false);

    return rows.map<ClaimRequest>(ClaimRequest.fromMap).toList();
  }

  Future<ClaimRequest> createClaim({
    required ItemReport item,
    required String claimantId,
    required String claimantName,
    required String verificationNote,
    required String contactInfo,
  }) async {
    final inserted = await _client
        .from('claim_requests')
        .insert({
          'item_id': item.id,
          'claimant_id': claimantId,
          'claimant_name': claimantName,
          'verification_note': verificationNote.trim(),
          'contact_info': contactInfo.trim(),
        })
        .select(
          'id, item_id, claimant_name, verification_note, contact_info, status, created_at, item_reports(title, report_type, category, location, faculty)',
        )
        .single();

    return ClaimRequest.fromMap(inserted);
  }
}
