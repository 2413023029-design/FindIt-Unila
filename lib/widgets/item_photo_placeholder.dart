import 'package:material_ui/material_ui.dart';

import '../core/constants/unila_data.dart';
import '../core/theme/app_theme.dart';
import '../models/item_report.dart';

/// Visual placeholder modern untuk foto barang pada card maupun halaman detail.
class ItemPhotoPlaceholder extends StatelessWidget {
  const ItemPhotoPlaceholder({
    super.key,
    required this.category,
    required this.colorName,
    required this.type,
    this.photoLabel,
    this.width = 76,
    this.height = 76,
    this.borderRadius = 14,
    this.showPhotoLabel = false,
  });

  final String category;
  final String colorName;
  final ReportType type;
  final String? photoLabel;
  final double? width;
  final double height;
  final double borderRadius;
  final bool showPhotoLabel;

  @override
  Widget build(BuildContext context) {
    final accent = UnilaData.colorFromName(colorName);
    final isLost = type == ReportType.lost;
    final tint = isLost ? AppColors.lostRed : AppColors.primaryBlue;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            AppColors.softBlue,
            tint.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(showPhotoLabel ? 14 : 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  UnilaData.categoryIcon(category),
                  size: showPhotoLabel ? 36 : 26,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (showPhotoLabel) ...[
                const SizedBox(height: 10),
                Text(
                  photoLabel ?? 'Belum ada foto terlampir',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: showPhotoLabel ? 22 : 14,
              height: showPhotoLabel ? 22 : 14,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
          if (photoLabel != null && !showPhotoLabel)
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 11,
                  color: AppColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
