import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_card.dart';
import 'icon_chip.dart';

/// A compact pastel tool card for the horizontal "Explore tools" row on Home.
///
/// Fixed width so several scroll side by side.
class LearningToolCard extends StatelessWidget {
  const LearningToolCard({
    super.key,
    required this.accent,
    required this.icon,
    required this.label,
    this.width = 150,
    this.onTap,
  });

  final GurukulaAccent accent;
  final IconData icon;
  final String label;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = accent.onFill;
    return SizedBox(
      width: width,
      child: AppCard(
        color: accent.fill,
        showBorder: false,
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconChip(
              icon: icon,
              iconColor: ink,
              background: Colors.white.withValues(alpha: 0.45),
              size: 42,
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: ink),
            ),
          ],
        ),
      ),
    );
  }
}
