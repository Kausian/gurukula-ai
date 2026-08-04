import 'package:flutter/widgets.dart';

/// Small, dependency-free responsive helpers used across Gurukula AI
/// (v1.31.1). Deliberately tiny — no overengineering. The goal is to keep the
/// app comfortable on small Android phones and large font scales without
/// disabling accessibility or reflowing the whole design.
///
/// Nothing here forces a fixed text scale globally. [clampedTextScaler] is a
/// targeted tool for a few label-only, fixed-height chrome elements (a
/// horizontal card strip, a chip row) so their text can grow — up to a sane
/// cap — instead of clipping.

/// Coarse width buckets, aligned with Material's window-size classes but scoped
/// to what this phone-first app actually needs.
enum ScreenSize {
  /// Phones in portrait (and small windows): < 600dp wide.
  compact,

  /// Large phones in landscape and small tablets/foldables: 600–839dp.
  medium,

  /// Tablets and wide windows: >= 840dp.
  expanded,
}

/// Responsive layout helpers. All read from the ambient [MediaQuery], so call
/// them inside `build`.
class Responsive {
  Responsive._();

  /// The width bucket for the current context.
  static ScreenSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 840) return ScreenSize.expanded;
    if (width >= 600) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static bool isCompact(BuildContext context) =>
      sizeOf(context) == ScreenSize.compact;

  /// A comfortable, size-aware horizontal page padding. Screens already use a
  /// 20dp gutter on phones; this keeps that and only widens on bigger windows.
  static double horizontalPadding(BuildContext context) {
    switch (sizeOf(context)) {
      case ScreenSize.compact:
        return 20;
      case ScreenSize.medium:
        return 28;
      case ScreenSize.expanded:
        return 32;
    }
  }

  /// The widest a form / reading column should ever get, so content stays
  /// readable and doesn't stretch edge-to-edge on tablets and foldables.
  static const double maxContentWidth = 560;

  /// A [TextScaler] that honors the user's system font size but caps how far it
  /// can grow, for the few fixed-height chrome elements where unbounded growth
  /// would clip. Not used for body content, which should scale freely.
  static TextScaler clampedTextScaler(BuildContext context,
      {double max = 1.3}) {
    return MediaQuery.textScalerOf(context).clamp(maxScaleFactor: max);
  }

  /// Scales a base pixel height by the (clamped) system text scale, so a
  /// fixed-height strip of text cards grows with the font instead of clipping.
  static double scaledHeight(BuildContext context, double base,
      {double maxScale = 1.5}) {
    final scale =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: maxScale);
    return scale.scale(base);
  }
}

/// Centers and width-constrains its [child] on wide screens (tablets,
/// foldables, large landscape windows) while staying full-width on phones.
///
/// Handy for forms and reading columns: wrap the scroll child so it never
/// stretches past [maxWidth] on big displays.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
