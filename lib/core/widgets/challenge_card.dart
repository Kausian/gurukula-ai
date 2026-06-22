import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_card.dart';
import 'icon_chip.dart';

/// A bold, filled "today's boost" card that nudges a small study action.
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    this.icon = Icons.bolt_rounded,
    this.onTap,
  });

  final GurukulaAccent accent;
  final String eyebrow;
  final String title;
  final String actionLabel;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = accent.onFill;
    return AppCard(
      color: accent.fill,
      showBorder: false,
      onTap: onTap,
      child: Row(
        children: [
          IconChip(
            icon: icon,
            iconColor: ink,
            background: Colors.white.withValues(alpha: 0.45),
            size: 50,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: ink.withValues(alpha: 0.65)),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: ink),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: accent.fill),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
