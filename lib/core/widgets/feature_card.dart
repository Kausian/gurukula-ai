import 'package:flutter/material.dart';

import 'app_card.dart';
import 'icon_chip.dart';

/// A benefit row: icon chip, title and a short description.
///
/// Used on the Welcome screen and the Idea Lab mode list.
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconChip(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                size: 20, color: theme.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}
