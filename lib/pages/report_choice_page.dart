import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';
import '../models/item_report.dart';
import 'report_form_page.dart';

/// Halaman 6: Pilihan jenis laporan (Barang Hilang atau Barang Temuan).
class ReportChoicePage extends StatelessWidget {
  const ReportChoicePage({super.key});

  void _openForm(BuildContext context, ReportType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportFormPage(initialType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apa yang ingin Anda laporkan?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih jenis laporan di bawah ini agar sistem Smart Match dapat membantu mencocokkan barang lebih cepat.',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ChoiceCard(
              title: 'Lapor Barang Hilang',
              description:
                  'Laporkan barang milik Anda yang tertinggal atau hilang di area kampus UNILA.',
              badgeText: 'Kehilangan',
              icon: Icons.search_off_rounded,
              accentColor: AppColors.lostRed,
              backgroundColor: AppColors.lostRedBg,
              onTap: () => _openForm(context, ReportType.lost),
            ),
            const SizedBox(height: 14),
            _ChoiceCard(
              title: 'Lapor Barang Temuan',
              description:
                  'Laporkan barang yang Anda temukan di kampus agar pemilik sah dapat mengajukan klaim.',
              badgeText: 'Penemuan',
              icon: Icons.volunteer_activism_rounded,
              accentColor: AppColors.primaryBlue,
              backgroundColor: AppColors.lightBlue,
              onTap: () => _openForm(context, ReportType.found),
            ),
            const SizedBox(height: 22),
            Card(
              color: AppColors.softBlue,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tips Laporan Cepat Ditemukan',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _TipRow(
                      text: 'Cantumkan ciri khusus seperti stiker, goresan, atau gantungan.',
                    ),
                    SizedBox(height: 6),
                    _TipRow(
                      text: 'Sebutkan gedung, ruang kuliah, atau titik lokasi secara spesifik.',
                    ),
                    SizedBox(height: 6),
                    _TipRow(
                      text: 'Lampirkan foto barang yang jelas untuk mempercepat verifikasi klaim.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final String badgeText;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}
