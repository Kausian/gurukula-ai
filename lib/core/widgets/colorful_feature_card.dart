import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_card.dart';
import 'icon_chip.dart';

/// A vivid, pastel-filled feature card with a big icon chip.
///
/// Used in grids on the Welcome screen. High personality: the whole surface
/// takes the accent color, with dark ink text on top.
class ColorfulFeatureCard extends StatelessWidget {
  const ColorfulFeatureCard({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final GurukulaAccent accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = accent.onFill;
    return AppCard(
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
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
                fontSize: 16.5, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: ink.withValues(alpha: 0.72)),
          ),
        ],
      ),
    );
  }
}
