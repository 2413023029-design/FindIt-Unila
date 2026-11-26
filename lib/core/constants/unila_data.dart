import 'package:material_ui/material_ui.dart';

/// Data referensi kampus Universitas Lampung (UNILA) & helper format tanggal.
class UnilaData {
  UnilaData._();

  static const String appName = 'FindIt UNILA';
  static const String slogan = 'Lost Something? Find It Here!';

  static const List<String> faculties = [
    'Fakultas Teknik (FT)',
    'Fakultas Matematika & IPA (FMIPA)',
    'Fakultas Ekonomi & Bisnis (FEB)',
    'Fakultas Hukum (FH)',
    'Fakultas Ilmu Sosial & Ilmu Politik (FISIP)',
    'Fakultas Keguruan & Ilmu Pendidikan (FKIP)',
    'Fakultas Pertanian (FP)',
    'Fakultas Kedokteran (FK)',
    'UPT Perpustakaan & Rektorat',
  ];

  static const List<String> categories = [
    'Elektronik',
    'Dokumen & Kartu',
    'Dompet & Tas',
    'Kunci',
    'Aksesoris & Pakaian',
    'Perlengkapan Kuliah',
    'Lainnya',
  ];

  static const List<String> commonColors = [
    'Hitam',
    'Putih',
    'Biru',
    'Navy',
    'Abu-abu',
    'Cokelat',
    'Merah',
    'Hijau',
    'Silver',
  ];

  static const List<String> photoPresets = [
    'Foto Kamera Kampus',
    'Foto Galeri Barang',
    'Foto Detail Ciri Khusus',
  ];

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Elektronik':
        return Icons.devices_rounded;
      case 'Dokumen & Kartu':
        return Icons.badge_rounded;
      case 'Dompet & Tas':
        return Icons.backpack_rounded;
      case 'Kunci':
        return Icons.vpn_key_rounded;
      case 'Aksesoris & Pakaian':
        return Icons.checkroom_rounded;
      case 'Perlengkapan Kuliah':
        return Icons.menu_book_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  static Color colorFromName(String colorName) {
    final normalized = colorName.toLowerCase();
    if (normalized.contains('hitam')) return const Color(0xFF1E293B);
    if (normalized.contains('putih')) return const Color(0xFFE2E8F0);
    if (normalized.contains('navy')) return const Color(0xFF0B1F3A);
    if (normalized.contains('biru')) return const Color(0xFF1E88E5);
    if (normalized.contains('abu')) return const Color(0xFF64748B);
    if (normalized.contains('silver')) return const Color(0xFF94A3B8);
    if (normalized.contains('cokelat')) return const Color(0xFF7C4A2D);
    if (normalized.contains('merah')) return const Color(0xFFD9383A);
    if (normalized.contains('hijau')) return const Color(0xFF0F9D58);
    if (normalized.contains('kuning')) return const Color(0xFFEAB308);
    return const Color(0xFF1565C0);
  }

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day $month ${date.year}';
  }
}
