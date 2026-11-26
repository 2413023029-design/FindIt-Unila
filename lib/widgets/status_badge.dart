import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';
import '../models/claim_request.dart';
import '../models/item_report.dart';

/// Pill badge reusable untuk status laporan, jenis laporan, atau status klaim.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.icon,
  });

  factory StatusBadge.reportType(ReportType type) {
    final isLost = type == ReportType.lost;
    return StatusBadge(
      label: type.label,
      textColor: isLost ? AppColors.lostRed : AppColors.foundGreen,
      backgroundColor: isLost ? AppColors.lostRedBg : AppColors.foundGreenBg,
      icon: isLost ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
    );
  }

  factory StatusBadge.reportStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.active:
        return StatusBadge(
          label: status.label,
          textColor: AppColors.primaryBlue,
          backgroundColor: AppColors.lightBlue,
        );
      case ReportStatus.claimed:
        return StatusBadge(
          label: status.label,
          textColor: AppColors.warningAmber,
          backgroundColor: AppColors.warningAmberBg,
        );
      case ReportStatus.resolved:
        return StatusBadge(
          label: status.label,
          textColor: AppColors.foundGreen,
          backgroundColor: AppColors.foundGreenBg,
        );
    }
  }

  factory StatusBadge.claimStatus(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.pending:
        return StatusBadge(
          label: status.label,
          textColor: AppColors.warningAmber,
          backgroundColor: AppColors.warningAmberBg,
          icon: Icons.hourglass_top_rounded,
        );
      case ClaimStatus.approved:
        return StatusBadge(
          label: status.label,
          textColor: AppColors.foundGreen,
          backgroundColor: AppColors.foundGreenBg,
          icon: Icons.verified_rounded,
        );
      case ClaimStatus.rejected:
        return StatusBadge(
          label: status.label,
          textColor: AppColors.lostRed,
          backgroundColor: AppColors.lostRedBg,
          icon: Icons.cancel_outlined,
        );
    }
  }

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
