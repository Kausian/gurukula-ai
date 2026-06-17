import 'package:flutter/material.dart';

import 'app_card.dart';
import 'icon_chip.dart';

/// A tappable quick-action tile: icon chip, label and optional subtitle.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconChip(icon: icon, color: color, size: 40),
          const SizedBox(height: 14),
          Text(label, style: theme.textTheme.titleSmall),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
