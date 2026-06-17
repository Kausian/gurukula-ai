import 'package:flutter/material.dart';

/// A soft circular chip holding an icon.
///
/// Two common uses: a tinted chip on a neutral surface (pass [color]), or a
/// light chip on a colorful card (pass [background] white-ish and [iconColor]
/// the card's dark ink).
class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    this.color,
    this.iconColor,
    this.background,
    this.size = 46,
  });

  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final base = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? base.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor ?? base, size: size * 0.5),
    );
  }
}
