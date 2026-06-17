import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Visual tone for a [StatusBadge].
enum BadgeTone { neutral, info, success, accent }

/// A small pill that communicates state: ready, mock mode, coming soon, saved.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(theme);
    final hasLeading = showDot || icon != null;
    return Container(
      padding: EdgeInsets.fromLTRB(hasLeading ? 10 : 12, 6, 12, 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Color _color(ThemeData theme) {
    switch (tone) {
      case BadgeTone.neutral:
        return theme.colorScheme.onSurfaceVariant;
      case BadgeTone.info:
        return theme.colorScheme.primary;
      case BadgeTone.success:
        return AppColors.success;
      case BadgeTone.accent:
        return theme.colorScheme.primary;
    }
  }
}
