import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';

/// Logo modern FindIt UNILA yang dapat dipakai di Splash, Login, dan Register.
class FindItLogo extends StatelessWidget {
  const FindItLogo({
    super.key,
    this.size = 76,
    this.lightMode = false,
  });

  final double size;
  final bool lightMode;

  @override
  Widget build(BuildContext context) {
    final bgGradient = lightMode
        ? const LinearGradient(
            colors: [AppColors.white, AppColors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.navy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final iconColor = lightMode ? AppColors.primaryBlue : AppColors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: (lightMode ? AppColors.navy : AppColors.primaryBlue)
                .withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: size * 0.54,
            color: iconColor,
          ),
          Positioned(
            right: size * 0.16,
            bottom: size * 0.16,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: BoxDecoration(
                color: lightMode ? AppColors.navy : AppColors.accentBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: size * 0.13,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
