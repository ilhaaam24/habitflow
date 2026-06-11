import 'package:flutter/material.dart';
import '../../shared/models/badge_model.dart';
import '../../core/theme/app_colors.dart';

class BadgeUnlockDialog extends StatelessWidget {
  final BadgeModel badge;

  const BadgeUnlockDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.borderOf(context);
    final bgColor = AppColors.dialogBgOf(context);
    final textColor = AppColors.textOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final greenColor = AppColors.accentGreenOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Icon container
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Color(badge.colorValue),
                border: Border.all(color: borderColor, width: 4),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: borderColor,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: const TextStyle(fontSize: 44),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "BADGE UNLOCKED! 🏆",
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 2,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.description.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: greenColor,
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "AWESOME! ⚡",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

