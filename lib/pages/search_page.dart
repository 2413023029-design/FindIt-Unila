import 'package:material_ui/material_ui.dart';

import '../core/constants/unila_data.dart';
import '../core/theme/app_theme.dart';
import '../models/item_report.dart';
import '../state/app_state.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';

/// Halaman 5: Pencarian daftar barang hilang & temuan dengan filter kategori dan fakultas.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    if (_searchController.text != appState.searchQuery) {
      _searchController.value = TextEditingValue(
        text: appState.searchQuery,
        selection: TextSelection.collapsed(offset: appState.searchQuery.length),
      );
    }

    final items = appState.filteredReports;
    final hasActiveFilters = appState.searchQuery.isNotEmpty ||
        appState.selectedCategory != null ||
        appState.selectedFaculty != null ||
        appState.selectedType != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Barang'),
        actions: [
          if (hasActiveFilters)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                appState.resetSearchFilters();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: appState.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Cari nama barang, warna, atau lokasi...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: appState.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              appState.setSearchQuery('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TypeFilterChip(
                        label: 'Semua',
                        selected: appState.selectedType == null,
                        onSelected: () => appState.setSelectedType(null),
                      ),
                      const SizedBox(width: 8),
                      _TypeFilterChip(
                        label: 'Barang Hilang',
                        selected: appState.selectedType == ReportType.lost,
                        onSelected: () =>
                            appState.setSelectedType(ReportType.lost),
                      ),
                      const SizedBox(width: 8),
                      _TypeFilterChip(
                        label: 'Barang Temuan',
                        selected: appState.selectedType == ReportType.found,
                        onSelected: () =>
                            appState.setSelectedType(ReportType.found),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: appState.selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Semua Kategori'),
                          ),
                          ...UnilaData.categories.map(
                            (category) => DropdownMenuItem<String?>(
                              value: category,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: appState.setSelectedCategory,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: appState.selectedFaculty,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Fakultas',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Semua Fakultas'),
                          ),
                          ...UnilaData.faculties.map(
                            (faculty) => DropdownMenuItem<String?>(
                              value: faculty,
                              child: Text(
                                faculty,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: appState.setSelectedFaculty,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
            child: Row(
              children: [
                Text(
                  'Menampilkan ${items.length} laporan',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
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
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Barang belum ditemukan',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Coba ubah kata kunci atau reset filter kategori dan fakultas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              appState.resetSearchFilters();
                            },
                            child: const Text('Reset Semua Filter'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = items[index];
                      return ItemCard(
                        report: report,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ItemDetailPage(report: report),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.softBlue,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.navy,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      side: BorderSide(
        color: selected ? AppColors.primaryBlue : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
