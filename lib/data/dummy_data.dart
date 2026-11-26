import '../models/claim_request.dart';
import '../models/item_report.dart';
import '../models/user_profile.dart';

/// Kumpulan data dummy sementara untuk menampilkan contoh laporan dan klaim.
class DummyData {
  DummyData._();

  static const UserProfile defaultUser = UserProfile(
    id: 'usr-001',
    fullName: 'Rafi Pratama',
    email: 'rafi.pratama@students.unila.ac.id',
    faculty: 'Fakultas Teknik (FT)',
    npm: '2215061042',
    phone: '0812-7890-3344',
    smartMatchNotifications: true,
  );

  static List<ItemReport> initialReports() {
    final now = DateTime.now();
    return [
      ItemReport(
        id: 'rep-101',
        title: 'Powerbank Anker 10.000 mAh',
        category: 'Elektronik',
        type: ReportType.found,
        status: ReportStatus.active,
        colorName: 'Hitam',
        description:
            'Ditemukan di meja pojok lantai 2 Gedung H dekat stop kontak. Ada stiker kecil biru di bagian belakang.',
        faculty: 'Fakultas Teknik (FT)',
        location: 'Gedung H Lantai 2, Ruang H2.3',
        date: now.subtract(const Duration(hours: 4)),
        reporterName: 'Nadia Kusuma',
        reporterFaculty: 'Fakultas Teknik (FT)',
        photoLabel: 'Foto Kamera Kampus',
      ),
      ItemReport(
        id: 'rep-102',
        title: 'Powerbank Hitam Anker',
        category: 'Elektronik',
        type: ReportType.lost,
        status: ReportStatus.active,
        colorName: 'Hitam',
        description:
            'Tertinggal setelah kelas Jaringan Komputer pukul 13.00. Terdapat stiker biru kecil pada bodi.',
        faculty: 'Fakultas Teknik (FT)',
        location: 'Gedung H Teknik Elektro',
        date: now.subtract(const Duration(hours: 6)),
        reporterName: 'Rafi Pratama',
        reporterFaculty: 'Fakultas Teknik (FT)',
        photoLabel: 'Foto Galeri Barang',
        isUserOwned: true,
      ),
      ItemReport(
        id: 'rep-103',
        title: 'KTM a.n. Dinda Larasati (FMIPA)',
        category: 'Dokumen & Kartu',
        type: ReportType.found,
        status: ReportStatus.active,
        colorName: 'Biru',
        description:
            'Kartu Tanda Mahasiswa UNILA ditemukan di area parkir utara dekat GSG. Disimpan bersama holder bening.',
        faculty: 'Fakultas Matematika & IPA (FMIPA)',
        location: 'Parkiran Utara Dekat GSG',
        date: now.subtract(const Duration(days: 1)),
        reporterName: 'Bagas Saputra',
        reporterFaculty: 'Fakultas Matematika & IPA (FMIPA)',
        photoLabel: 'Foto Kamera Kampus',
      ),
      ItemReport(
        id: 'rep-104',
        title: 'Tumbler Corkcicle Navy 475ml',
        category: 'Perlengkapan Kuliah',
        type: ReportType.found,
        status: ReportStatus.active,
        colorName: 'Navy',
        description:
            'Tertinggal di ruang baca lantai 3 UPT Perpustakaan. Tutup berwarna hitam dan ada sedikit goresan di bawah.',
        faculty: 'UPT Perpustakaan & Rektorat',
        location: 'UPT Perpustakaan Lantai 3',
        date: now.subtract(const Duration(days: 1, hours: 5)),
        reporterName: 'Siti Rahmawati',
        reporterFaculty: 'Fakultas Ekonomi & Bisnis (FEB)',
        photoLabel: 'Foto Detail Ciri Khusus',
      ),
      ItemReport(
        id: 'rep-105',
        title: 'Kunci Motor Honda + Gantungan UNILA',
        category: 'Kunci',
        type: ReportType.lost,
        status: ReportStatus.active,
        colorName: 'Hitam',
        description:
            'Hilang di sekitar Kantin FEB atau jalan menuju Masjid Al-Wasi\'i. Gantungan kunci bertuliskan Teknik Informatika.',
        faculty: 'Fakultas Ekonomi & Bisnis (FEB)',
        location: 'Kantin FEB & Jalur Masjid Al-Wasi\'i',
        date: now.subtract(const Duration(days: 2)),
        reporterName: 'Andika Wijaya',
        reporterFaculty: 'Fakultas Teknik (FT)',
      ),
      ItemReport(
        id: 'rep-106',
        title: 'Kalkulator Ilmiah Casio fx-991EX',
        category: 'Elektronik',
        type: ReportType.found,
        status: ReportStatus.claimed,
        colorName: 'Hitam',
        description:
            'Ditemukan di laci meja ruang kuliah A1.2 setelah ujian tengah semester. Casing penutup belakang masih lengkap.',
        faculty: 'Fakultas Matematika & IPA (FMIPA)',
        location: 'Gedung MIPA Ruang A1.2',
        date: now.subtract(const Duration(days: 3)),
        reporterName: 'Hendra Gunawan',
        reporterFaculty: 'Fakultas Matematika & IPA (FMIPA)',
        photoLabel: 'Foto Kamera Kampus',
      ),
      ItemReport(
        id: 'rep-107',
        title: 'Dompet Kulit Cokelat Lipat',
        category: 'Dompet & Tas',
        type: ReportType.lost,
        status: ReportStatus.active,
        colorName: 'Cokelat',
        description:
            'Berisi kartu ATM dan SIM C a.n. Rizky Maulana. Terakhir terlihat di area taman belakang Fakultas Hukum.',
        faculty: 'Fakultas Hukum (FH)',
        location: 'Taman Belakang Fakultas Hukum',
        date: now.subtract(const Duration(days: 3, hours: 8)),
        reporterName: 'Rizky Maulana',
        reporterFaculty: 'Fakultas Hukum (FH)',
      ),
      ItemReport(
        id: 'rep-108',
        title: 'Kacamata Frame Tipis Silver',
        category: 'Aksesoris & Pakaian',
        type: ReportType.found,
        status: ReportStatus.resolved,
        colorName: 'Silver',
        description:
            'Ditemukan di bangku tunggu gedung A FKIP bersama hardcase berwarna abu-abu.',
        faculty: 'Fakultas Keguruan & Ilmu Pendidikan (FKIP)',
        location: 'Lobi Gedung A FKIP',
        date: now.subtract(const Duration(days: 5)),
        reporterName: 'Rafi Pratama',
        reporterFaculty: 'Fakultas Teknik (FT)',
        photoLabel: 'Foto Galeri Barang',
        isUserOwned: true,
      ),
    ];
  }

  static List<ClaimRequest> initialClaims() {
    final now = DateTime.now();
    return [
      ClaimRequest(
        id: 'clm-201',
        itemId: 'rep-106',
        itemTitle: 'Kalkulator Ilmiah Casio fx-991EX',
        itemType: ReportType.found,
        itemCategory: 'Elektronik',
        itemLocation: 'Gedung MIPA Ruang A1.2',
        itemFaculty: 'Fakultas Matematika & IPA (FMIPA)',
        claimantName: defaultUser.fullName,
        verificationNote:
            'Ada inisial RP di bagian dalam penutup baterai dan goresan halus di tombol AC.',
        contactInfo: defaultUser.phone,
        createdAt: now.subtract(const Duration(days: 2)),
        status: ClaimStatus.pending,
      ),
      ClaimRequest(
        id: 'clm-202',
        itemId: 'rep-104',
        itemTitle: 'Tumbler Corkcicle Navy 475ml',
        itemType: ReportType.found,
        itemCategory: 'Perlengkapan Kuliah',
        itemLocation: 'UPT Perpustakaan Lantai 3',
        itemFaculty: 'UPT Perpustakaan & Rektorat',
        claimantName: defaultUser.fullName,
        verificationNote:
            'Di bagian alas ada label nama kecil bertuliskan Rafi dan sedikit penyok di sisi kanan.',
        contactInfo: defaultUser.phone,
        createdAt: now.subtract(const Duration(days: 4)),
        status: ClaimStatus.approved,
      ),
    ];
  }
}
