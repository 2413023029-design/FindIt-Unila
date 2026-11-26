import 'package:material_ui/material_ui.dart';

import '../core/constants/unila_data.dart';
import '../core/theme/app_theme.dart';
import '../models/item_report.dart';
import '../state/app_state.dart';
import '../widgets/item_photo_placeholder.dart';
import '../widgets/status_badge.dart';

/// Halaman 10: Detail informasi barang dan pengajuan klaim jika sesuai.
class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({
    super.key,
    required this.report,
  });

  final ItemReport report;

  void _openClaimBottomSheet(BuildContext context, AppState appState, ItemReport current) {
    final noteController = TextEditingController();
    final contactController = TextEditingController(
      text: appState.currentUser.phone,
    );
    final formKey = GlobalKey<FormState>();
    final isFoundItem = current.type == ReportType.found;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isFoundItem
                      ? 'Ajukan Klaim Kepemilikan'
                      : 'Konfirmasi Penemuan Barang',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isFoundItem
                      ? 'Jelaskan ciri khusus atau bukti kepemilikan agar penemu dapat memverifikasi klaim Anda.'
                      : 'Jelaskan di mana dan bagaimana kondisi barang saat Anda menemukannya.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isFoundItem
                        ? 'Ciri Khusus / Bukti Kepemilikan'
                        : 'Keterangan Penemuan',
                    hintText: isFoundItem
                        ? 'Contoh: Ada stiker inisial di belakang atau isi kartu atas nama saya'
                        : 'Contoh: Saya temukan di ruang H2.3 dan saat ini diamankan di pos satpam',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length < 10) {
                      return 'Mohon isi keterangan minimal 10 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor WhatsApp / Kontak Aktif',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length < 8) {
                      return 'Masukkan nomor kontak yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final error = await appState.submitClaim(
                      item: current,
                      verificationNote: noteController.text,
                      contactInfo: contactController.text,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!context.mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFoundItem
                              ? 'Pengajuan klaim berhasil dikirim. Pantau statusnya di halaman Riwayat.'
                              : 'Konfirmasi penemuan terkirim dan tercatat di halaman Riwayat.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user_outlined),
                  label: Text(
                    isFoundItem ? 'Kirim Pengajuan Klaim' : 'Kirim Konfirmasi',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final currentReport = appState.allReports.firstWhere(
      (r) => r.id == report.id,
      orElse: () => report,
    );
    final alreadyClaimed = appState.hasClaimedItem(currentReport.id);
    final canClaim = !currentReport.isUserOwned &&
        currentReport.status != ReportStatus.resolved &&
        !alreadyClaimed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ItemPhotoPlaceholder(
              category: currentReport.category,
              colorName: currentReport.colorName,
              type: currentReport.type,
              photoLabel: currentReport.photoLabel,
              width: double.infinity,
              height: 190,
              borderRadius: 20,
              showPhotoLabel: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge.reportType(currentReport.type),
                StatusBadge.reportStatus(currentReport.status),
                StatusBadge(
                  label: currentReport.category,
                  textColor: AppColors.navy,
                  backgroundColor: AppColors.softBlue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              currentReport.title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi Barang',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentReport.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailInfoRow(
                      icon: Icons.palette_outlined,
                      label: 'Warna',
                      value: currentReport.colorName,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _DetailInfoRow(
                      icon: Icons.account_balance_outlined,
                      label: 'Fakultas / Area',
                      value: currentReport.faculty,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _DetailInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Lokasi Kejadian',
                      value: currentReport.location,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _DetailInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal',
                      value: UnilaData.formatDate(currentReport.date),
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _DetailInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Pelapor',
                      value:
                          '${currentReport.reporterName} (${currentReport.reporterFaculty})',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (alreadyClaimed)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningAmberBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.warningAmber.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.warningAmber,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Anda sudah mengajukan klaim untuk barang ini. Cek statusnya di menu Riwayat.',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (currentReport.isUserOwned)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ini adalah laporan yang Anda buat. Anda dapat memperbarui statusnya dari menu Riwayat.',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: canClaim
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _openClaimBottomSheet(context, appState, currentReport),
                  icon: Icon(
                    currentReport.type == ReportType.found
                        ? Icons.verified_user_outlined
                        : Icons.handshake_outlined,
                  ),
                  label: Text(
                    currentReport.type == ReportType.found
                        ? 'Ajukan Klaim Barang'
                        : 'Saya Menemukan Barang Ini',
                  ),
                ),
              ),
            )
          : currentReport.isUserOwned &&
                  currentReport.status != ReportStatus.resolved
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final error = await appState.updateReportStatus(
                          currentReport.id,
                          ReportStatus.resolved,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error ?? 'Laporan ditandai selesai.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Tandai Sudah Selesai'),
                    ),
                  ),
                )
              : null,
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
