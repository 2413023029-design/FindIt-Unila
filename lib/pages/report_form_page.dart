import 'package:material_ui/material_ui.dart';

import '../core/constants/unila_data.dart';
import '../core/theme/app_theme.dart';
import '../models/item_report.dart';
import '../state/app_state.dart';
import '../widgets/item_photo_placeholder.dart';

/// Halaman 7: Form Laporan barang hilang atau temuan.
class ReportFormPage extends StatefulWidget {
  const ReportFormPage({
    super.key,
    required this.initialType,
  });

  final ReportType initialType;

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _colorController = TextEditingController(text: 'Hitam');
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  late ReportType _reportType;
  String _selectedCategory = UnilaData.categories.first;
  String _selectedFaculty = UnilaData.faculties.first;
  DateTime _selectedDate = DateTime.now();
  String? _selectedPhotoLabel;

  @override
  void initState() {
    super.initState();
    _reportType = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      helpText: 'Pilih Tanggal Kejadian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _pickPhotoSource() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lampirkan Foto Barang',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih contoh sumber foto untuk pratinjau laporan tahap UI.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightBlue,
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                  ),
                  title: const Text('Ambil dari Kamera'),
                  subtitle: const Text('Simulasi foto langsung di lokasi kampus'),
                  onTap: () {
                    setState(() => _selectedPhotoLabel = UnilaData.photoPresets[0]);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightBlue,
                    child: Icon(Icons.photo_library_rounded, color: AppColors.primaryBlue),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  subtitle: const Text('Simulasi foto barang dari penyimpanan HP'),
                  onTap: () {
                    setState(() => _selectedPhotoLabel = UnilaData.photoPresets[1]);
                    Navigator.pop(ctx);
                  },
                ),
                if (_selectedPhotoLabel != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.lostRedBg,
                      child: Icon(Icons.delete_outline_rounded, color: AppColors.lostRed),
                    ),
                    title: const Text('Hapus Lampiran Foto'),
                    onTap: () {
                      setState(() => _selectedPhotoLabel = null);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final appState = AppStateScope.of(context);
    final error = await appState.addReport(
      type: _reportType,
      title: _titleController.text,
      category: _selectedCategory,
      colorName: _colorController.text,
      description: _descriptionController.text,
      faculty: _selectedFaculty,
      location: _locationController.text,
      date: _selectedDate,
      photoLabel: _selectedPhotoLabel,
    );
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Laporan ${_reportType.label.toLowerCase()} berhasil dikirim!',
        ),
      ),
    );

    appState.setTab(3); // Arahkan ke Riwayat untuk melihat laporan baru
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _reportType == ReportType.lost;

    return Scaffold(
      appBar: AppBar(
        title: Text('Form ${isLost ? 'Barang Hilang' : 'Barang Temuan'}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Laporan',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeSelectorButton(
                                label: 'Barang Hilang',
                                icon: Icons.search_off_rounded,
                                selected: isLost,
                                activeColor: AppColors.lostRed,
                                onTap: () => setState(
                                  () => _reportType = ReportType.lost,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TypeSelectorButton(
                                label: 'Barang Temuan',
                                icon: Icons.volunteer_activism_rounded,
                                selected: !isLost,
                                activeColor: AppColors.primaryBlue,
                                onTap: () => setState(
                                  () => _reportType = ReportType.found,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang',
                            hintText: 'Contoh: KTM UNILA, Powerbank Anker, Kunci Honda',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().length < 3) {
                              return 'Nama barang minimal 3 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: UnilaData.categories
                              .map(
                                (cat) => DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedCategory = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Foto Barang',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickPhotoSource,
                          borderRadius: BorderRadius.circular(16),
                          child: _selectedPhotoLabel != null
                              ? Column(
                                  children: [
                                    ItemPhotoPlaceholder(
                                      category: _selectedCategory,
                                      colorName: _colorController.text,
                                      type: _reportType,
                                      photoLabel: _selectedPhotoLabel,
                                      width: double.infinity,
                                      height: 140,
                                      borderRadius: 16,
                                      showPhotoLabel: true,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Ketuk untuk mengganti atau menghapus foto',
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 112,
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlue,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primaryBlue
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 30,
                                        color: AppColors.primaryBlue,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Unggah / Pilih Foto Barang',
                                        style: TextStyle(
                                          color: AppColors.navy,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Opsional, membantu proses verifikasi klaim',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _colorController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Warna',
                            hintText: 'Contoh: Hitam, Navy, Putih',
                            prefixIcon: Icon(Icons.palette_outlined),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Warna barang wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: UnilaData.commonColors.map((color) {
                            final isSelected =
                                _colorController.text.trim().toLowerCase() ==
                                    color.toLowerCase();
                            return ChoiceChip(
                              label: Text(color),
                              selected: isSelected,
                              selectedColor: AppColors.lightBlue,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) {
                                setState(() => _colorController.text = color);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi & Ciri Khusus',
                            hintText:
                                'Jelaskan kondisi barang, merek, stiker, atau isi di dalamnya...',
                            alignLabelWithHint: true,
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 42),
                              child: Icon(Icons.description_outlined),
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().length < 10) {
                              return 'Deskripsi minimal 10 karakter agar mudah dikenali';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedFaculty,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Fakultas / Area Kampus',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),
                          items: UnilaData.faculties
                              .map(
                                (faculty) => DropdownMenuItem<String>(
                                  value: faculty,
                                  child: Text(
                                    faculty,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedFaculty = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _locationController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Lokasi Spesifik',
                            hintText: 'Contoh: Gedung H Lantai 2, Kantin FEB, GSG',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().length < 3) {
                              return 'Lokasi wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Kejadian',
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                              suffixIcon: Icon(Icons.edit_calendar_outlined),
                            ),
                            child: Text(
                              UnilaData.formatDate(_selectedDate),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(
                    isLost ? 'Kirim Laporan Kehilangan' : 'Kirim Laporan Temuan',
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeSelectorButton extends StatelessWidget {
  const _TypeSelectorButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? activeColor : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
