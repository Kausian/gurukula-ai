import 'package:flutter/material.dart';

/// A named pastel accent used for Gurukula's colorful learning cards.
///
/// [fill] is the vivid pastel surface; [onFill] is the dark ink used for text
/// and icons on top of it. The same pastels read well in both light and dark
/// mode, so they are shared across themes.
class GurukulaAccent {
  const GurukulaAccent(this.fill, this.onFill);
  final Color fill;
  final Color onFill;
}

/// The shared pastel palette. Each role is used deliberately, not at random.
class AppAccents {
  AppAccents._();

  static const Color _ink = Color(0xFF1A1726);

  static const GurukulaAccent lavender = GurukulaAccent(Color(0xFFC2B6FF), _ink);
  static const GurukulaAccent lime = GurukulaAccent(Color(0xFFCFE97E), _ink);
  static const GurukulaAccent mint = GurukulaAccent(Color(0xFF92E8C8), _ink);
  static const GurukulaAccent coral = GurukulaAccent(Color(0xFFFFAD92), _ink);
  static const GurukulaAccent pink = GurukulaAccent(Color(0xFFFFA8CD), _ink);
  static const GurukulaAccent sky = GurukulaAccent(Color(0xFF9CCDFF), _ink);
}

/// Neutral tokens, split by mode. Pastels live in [AppAccents].
class AppColors {
  AppColors._();

  // ---- Dark (primary, premium look) ----
  static const Color darkBackground = Color(0xFF0E0F14); // deep ink
  static const Color darkSurface = Color(0xFF181A21); // charcoal cards
  static const Color darkSurfaceAlt = Color(0xFF21242E); // tinted fills
  static const Color darkBorder = Color(0xFF2A2E39); // hairline
  static const Color darkPrimary = Color(0xFF9F90FF); // soft lavender-violet
  static const Color darkOnPrimary = Color(0xFF161227);
  static const Color darkInk = Color(0xFFF3F1EA); // warm off-white
  static const Color darkMuted = Color(0xFF9AA0AD); // soft gray

  // ---- Light (playful, not plain white) ----
  static const Color lightBackground = Color(0xFFF4F3FB); // light lavender-gray
  static const Color lightSurface = Color(0xFFFCFBFF); // near-white cards
  static const Color lightSurfaceAlt = Color(0xFFEDEBF8); // tinted fills
  static const Color lightBorder = Color(0xFFE3E0F1); // soft blue-gray
  static const Color lightPrimary = Color(0xFF5B45E0); // deep blue-violet
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightInk = Color(0xFF1A1B2E); // deep navy
  static const Color lightMuted = Color(0xFF6B6E82); // muted

  static const Color success = Color(0xFF35B57E);
}

/// Central Material 3 theme for Gurukula (dark-first, light polished too).
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'PlusJakartaSans';

  static const double radiusSm = 14.0;
  static const double radius = 22.0;
  static const double radiusLg = 28.0;

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final onPrimary = isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: surfaceAlt,
      onPrimaryContainer: primary,
      secondary: AppAccents.lavender.fill,
      onSecondary: AppAccents.lavender.onFill,
      secondaryContainer: surfaceAlt,
      onSecondaryContainer: ink,
      surface: surface,
      onSurface: ink,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceAlt,
      surfaceContainerHigh: surfaceAlt,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
      error: const Color(0xFFE5675C),
      onError: Colors.white,
    );

    final textTheme = _textTheme(ink, muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(56),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: isDark ? 0.26 : 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 25, color: selected ? primary : muted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? primary : muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? surfaceAlt : ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? ink : surface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }

  /// Bold, expressive type scale (headings carry real weight).
  static TextTheme _textTheme(Color ink, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 34, fontWeight: FontWeight.w800, height: 1.1, color: ink, letterSpacing: -0.8),
      displaySmall: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, color: ink, letterSpacing: -0.6),
      headlineMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w800, height: 1.15, color: ink, letterSpacing: -0.6),
      headlineSmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, color: ink, letterSpacing: -0.4),
      titleLarge: TextStyle(
          fontSize: 19, fontWeight: FontWeight.w700, height: 1.25, color: ink, letterSpacing: -0.3),
      titleMedium: TextStyle(
          fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.3, color: ink),
      titleSmall: TextStyle(
          fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3, color: ink),
      bodyLarge: TextStyle(
          fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.45, color: ink),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, height: 1.5, color: muted),
      bodySmall: TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.45, color: muted),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, height: 1.2, color: ink),
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, color: muted),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, height: 1.2, color: muted, letterSpacing: 0.2),
    );
  }
}
