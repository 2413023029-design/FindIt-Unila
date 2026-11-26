import 'package:material_ui/material_ui.dart';

import '../core/constants/unila_data.dart';
import '../core/theme/app_theme.dart';
import '../models/claim_request.dart';
import '../models/item_report.dart';
import '../state/app_state.dart';
import '../widgets/item_card.dart';
import '../widgets/status_badge.dart';
import 'item_detail_page.dart';

/// Halaman 8: Riwayat laporan dan pengajuan klaim milik pengguna beserta statusnya.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final myReports = appState.userReports;
    final myClaims = appState.userClaims;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Aktivitas'),
          bottom: TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
            tabs: [
              Tab(text: 'Laporan Saya (${myReports.length})'),
              Tab(text: 'Klaim Saya (${myClaims.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReportsHistoryTab(reports: myReports),
            _ClaimsHistoryTab(claims: myClaims),
          ],
        ),
      ),
    );
  }
}

class _ReportsHistoryTab extends StatelessWidget {
  const _ReportsHistoryTab({required this.reports});

  final List<ItemReport> reports;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (reports.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.assignment_outlined,
        title: 'Belum ada laporan',
        message: 'Laporan barang hilang atau temuan yang Anda buat akan muncul di sini.',
        buttonLabel: 'Buat Laporan',
        onPressed: () => appState.setTab(2),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ItemCard(
              report: report,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ItemDetailPage(report: report),
                  ),
                );
              },
            ),
            if (report.status != ReportStatus.resolved)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final error = await appState.updateReportStatus(
                        report.id,
                        ReportStatus.resolved,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            error ?? 'Status laporan diperbarui menjadi Selesai.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                    label: const Text('Tandai Selesai'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ClaimsHistoryTab extends StatelessWidget {
  const _ClaimsHistoryTab({required this.claims});

  final List<ClaimRequest> claims;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (claims.isEmpty) {
      return _EmptyHistoryView(
        icon: Icons.verified_user_outlined,
        title: 'Belum ada pengajuan klaim',
        message: 'Klaim barang yang Anda ajukan akan tampil beserta status verifikasinya.',
        buttonLabel: 'Cari Barang',
        onPressed: () => appState.setTab(1),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: claims.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final claim = claims[index];
        final matchedReport = appState.allReports.where((r) => r.id == claim.itemId);

        return Card(
          child: InkWell(
            onTap: matchedReport.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ItemDetailPage(report: matchedReport.first),
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge.claimStatus(claim.status),
                      const Spacer(),
                      Text(
                        UnilaData.formatDate(claim.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    claim.itemTitle,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${claim.itemCategory} • ${claim.itemLocation}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bukti / Catatan Verifikasi:',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          claim.verificationNote,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
