import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme-aware color set. Access via `context.c.bg`, `context.c.text`, etc.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  static const AppColors darkColors = AppColors(
    bg: Color(0xFF000000),
    surface: Color(0xFF0A0A0A),
    surfaceRaised: Color(0xFF141414),
    border: Color(0xFF1E1E1E),
    text: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF888888),
    textTertiary: Color(0xFF555555),
  );

  static const AppColors lightColors = AppColors(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F7F7),
    surfaceRaised: Color(0xFFEEEEEE),
    border: Color(0xFFE0E0E0),
    text: Color(0xFF111111),
    textSecondary: Color(0xFF555555),
    textTertiary: Color(0xFF999999),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
  }) =>
      AppColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        border: border ?? this.border,
        text: text ?? this.text,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

/// Short-form access to themed colors: `context.c.bg`.
extension AppColorsX on BuildContext {
  AppColors get c =>
      Theme.of(this).extension<AppColors>() ?? AppColors.darkColors;
}

/// Pure-black minimalist design system.
class AppTheme {
  // ── Surfaces (dark) — kept for backwards compat / non-context callers ──
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceRaised = Color(0xFF141414);
  static const Color border = Color(0xFF1E1E1E);

  // ── Surfaces (light) ──
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F7F7);
  static const Color surfaceRaisedLight = Color(0xFFEEEEEE);
  static const Color borderLight = Color(0xFFE0E0E0);

  // ── Accents (theme-agnostic) ──
  static const Color accent = Color(0xFF00E5FF);
  static const Color green = Color(0xFF00E676);
  static const Color amber = Color(0xFFFFD740);
  static const Color red = Color(0xFFFF5252);
  static const Color gold = Color(0xFFD4AF37);

  // ── Text (dark) ──
  static const Color text = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF555555);

  // ── Text (light) ──
  static const Color textLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color textTertiaryLight = Color(0xFF999999);

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final tt = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: text,
      displayColor: text,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      extensions: const [AppColors.darkColors],
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: green,
        surface: surface,
        error: red,
      ),
      textTheme: tt.copyWith(
        headlineMedium: tt.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: tt.bodyMedium?.copyWith(color: textSecondary, height: 1.5),
        bodySmall: tt.bodySmall?.copyWith(color: textTertiary, fontSize: 12),
        labelLarge: tt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.12),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            color: sel ? text : textTertiary,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            fontSize: 11,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? accent : textTertiary,
            size: 22,
          );
        }),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceRaised,
        selectedColor: accent.withValues(alpha: 0.15),
        side: BorderSide(color: border),
        labelStyle: const TextStyle(color: text, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dividerColor: border,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: tt.bodyMedium?.copyWith(color: text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Light theme — provided for users who prefer light mode. Most screens were
  /// designed for the dark theme; widgets that hard-code [AppTheme.bg] etc.
  /// will still render dark. Material widgets respect this theme.
  static ThemeData light() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    final tt = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textLight,
      displayColor: textLight,
    );
    return base.copyWith(
      scaffoldBackgroundColor: bgLight,
      extensions: const [AppColors.lightColors],
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: green,
        surface: surfaceLight,
        error: red,
      ),
      textTheme: tt.copyWith(
        headlineMedium: tt.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium:
            tt.bodyMedium?.copyWith(color: textSecondaryLight, height: 1.5),
        bodySmall:
            tt.bodySmall?.copyWith(color: textTertiaryLight, fontSize: 12),
        labelLarge: tt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: const BorderSide(color: borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaisedLight,
        labelStyle: const TextStyle(color: textSecondaryLight),
        hintStyle: const TextStyle(color: textTertiaryLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.12),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            color: sel ? textLight : textTertiaryLight,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            fontSize: 11,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? accent : textTertiaryLight,
            size: 22,
          );
        }),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceRaisedLight,
        selectedColor: accent.withValues(alpha: 0.15),
        side: const BorderSide(color: borderLight),
        labelStyle: const TextStyle(color: textLight, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textLight,
          side: const BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dividerColor: borderLight,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaisedLight,
        contentTextStyle: tt.bodyMedium?.copyWith(color: textLight),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
