import 'package:material_ui/material_ui.dart';

import '../core/constants/unila_data.dart';
import '../core/theme/app_theme.dart';
import '../models/item_report.dart';
import '../state/app_state.dart';
import '../widgets/item_card.dart';
import '../widgets/section_header.dart';
import '../widgets/smart_match_card.dart';
import 'item_detail_page.dart';
import 'report_form_page.dart';

/// Halaman 4: Beranda FindIt UNILA.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReportForm(ReportType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportFormPage(initialType: type),
      ),
    );
  }

  void _openItemDetail(ItemReport report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemDetailPage(report: report),
      ),
    );
  }

  void _submitHomeSearch(AppState appState) {
    appState.openSearchWithQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final user = appState.currentUser;
    final smartMatches = appState.smartMatches;
    final recentReports = appState.recentReports.take(5).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 22,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user.fullName.split(' ').first}!',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.faculty,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.lightBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          tooltip: 'Notifikasi Smart Match',
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Notifikasi FindIt UNILA'),
                                content: Text(
                                  smartMatches.isEmpty
                                      ? 'Belum ada rekomendasi Smart Match terbaru saat ini.'
                                      : 'Ada ${smartMatches.length} rekomendasi Smart Match yang mungkin cocok dengan laporan atau area fakultas Anda.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    UnilaData.slogan,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submitHomeSearch(appState),
                    decoration: InputDecoration(
                      hintText: 'Cari barang hilang atau temuan (KTM, kunci...)',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryBlue,
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Cari sekarang',
                        onPressed: () => _submitHomeSearch(appState),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.navy,
                        ),
                      ),
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Lapor Barang\nHilang',
                        subtitle: 'Buat laporan kehilangan',
                        icon: Icons.campaign_rounded,
                        accentColor: AppColors.lostRed,
                        backgroundColor: AppColors.lostRedBg,
                        onTap: () => _openReportForm(ReportType.lost),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        title: 'Lapor Barang\nTemuan',
                        subtitle: 'Bantu kembalikan barang',
                        icon: Icons.volunteer_activism_rounded,
                        accentColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.lightBlue,
                        onTap: () => _openReportForm(ReportType.found),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Rekomendasi Smart Match',
                  subtitle: 'Pencocokan otomatis laporan hilang & temuan',
                  actionLabel: 'Cari Lainnya',
                  onActionTap: () => appState.setTab(1),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: smartMatches.isEmpty
                      ? Card(
                          child: Center(
                            child: Text(
                              'Belum ada kecocokan otomatis saat ini.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: smartMatches.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final match = smartMatches[index];
                            return SmartMatchCard(
                              match: match,
                              onTap: () => _openItemDetail(match.report),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Laporan Terbaru',
                  subtitle: 'Informasi kehilangan & penemuan di sekitar UNILA',
                  actionLabel: 'Lihat Semua',
                  onActionTap: () => appState.setTab(1),
                ),
                const SizedBox(height: 12),
                ...recentReports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ItemCard(
                      report: report,
                      onTap: () => _openItemDetail(report),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
