import 'package:flutter/material.dart';
import '../../shared/models/badge_model.dart';

class BadgeUnlockDialog extends StatelessWidget {
  final BadgeModel badge;

  const BadgeUnlockDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF0),
          border: Border.all(color: Colors.black, width: 4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(8, 8),
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
                border: Border.all(color: Colors.black, width: 4),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
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
            const Text(
              "BADGE UNLOCKED! 🏆",
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.description.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF6BCB77), // Green
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "AWESOME! ⚡",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.5,
                      color: Colors.black,
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
