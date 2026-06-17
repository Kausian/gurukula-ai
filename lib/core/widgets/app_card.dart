import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Base surface for every card in the app.
///
/// Adds an ink ripple and a subtle press-scale for a tactile, interactive
/// feel. Pass [color] with [showBorder] off for the filled pastel learning
/// cards, or leave defaults for a neutral bordered surface. The press-scale
/// honors the platform "reduce motion" setting.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
    this.borderColor,
    this.showBorder = true,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool showBorder;
  final double? radius;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final radius = BorderRadius.circular(widget.radius ?? AppTheme.radius);
    final scale = (_pressed && !reduceMotion) ? 0.97 : 1.0;

    final card = Material(
      color: widget.color ?? theme.colorScheme.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: _setPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: widget.showBorder
                ? Border.all(color: widget.borderColor ?? theme.colorScheme.outline)
                : null,
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: card,
    );
  }
}
