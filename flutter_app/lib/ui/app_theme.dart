import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Theme-aware color set. Access via `context.c.bg`, `context.c.text`, etc.
///
/// Calm, glassy palette in the spirit of Apple Stocks / Robinhood — tonal
/// near-blacks instead of pure black so OLED panels feel premium without
/// the harsh contrast. Semantic accents (positive/negative/caution/info)
/// allow tabs to reference meaning instead of literal colors.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceGlass,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.positive,
    required this.negative,
    required this.caution,
    required this.info,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceGlass; // translucent overlay used by glass cards/app bar
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color positive;
  final Color negative;
  final Color caution;
  final Color info;

  static const AppColors darkColors = AppColors(
    bg: Color(0xFF07090D),
    surface: Color(0xFF0B0E13),
    surfaceRaised: Color(0xFF11151C),
    surfaceGlass: Color(0xCC0B0E13),
    border: Color(0xFF1A2030),
    borderStrong: Color(0xFF243049),
    divider: Color(0xFF161C26),
    text: Color(0xFFF2F6FB),
    textSecondary: Color(0xFF9BA8BD),
    textTertiary: Color(0xFF5C6B82),
    positive: Color(0xFF3DDB9A),
    negative: Color(0xFFFF7B72),
    caution: Color(0xFFF9C74F),
    info: Color(0xFF00E5FF),
  );

  static const AppColors lightColors = AppColors(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F8FB),
    surfaceRaised: Color(0xFFEDF1F6),
    surfaceGlass: Color(0xCCFFFFFF),
    border: Color(0xFFE2E7EF),
    borderStrong: Color(0xFFCBD3DF),
    divider: Color(0xFFEBEFF5),
    text: Color(0xFF0E1422),
    textSecondary: Color(0xFF55617A),
    textTertiary: Color(0xFF8A95A8),
    positive: Color(0xFF12A55F),
    negative: Color(0xFFD9404C),
    caution: Color(0xFFB37800),
    info: Color(0xFF0086A8),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceGlass,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? positive,
    Color? negative,
    Color? caution,
    Color? info,
  }) => AppColors(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    surfaceGlass: surfaceGlass ?? this.surfaceGlass,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    divider: divider ?? this.divider,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    positive: positive ?? this.positive,
    negative: negative ?? this.negative,
    caution: caution ?? this.caution,
    info: info ?? this.info,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Short-form access to themed colors: `context.c.bg`.
extension AppColorsX on BuildContext {
  AppColors get c =>
      Theme.of(this).extension<AppColors>() ?? AppColors.darkColors;
}

/// Calm-glass minimalist design system.
class AppTheme {
  // ── Surfaces (dark) — softened near-blacks for OLED-friendly premium feel ──
  static const Color bg = Color(0xFF07090D);
  static const Color surface = Color(0xFF0B0E13);
  static const Color surfaceRaised = Color(0xFF11151C);
  static const Color border = Color(0xFF1A2030);

  // ── Surfaces (light) ──
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF6F8FB);
  static const Color surfaceRaisedLight = Color(0xFFEDF1F6);
  static const Color borderLight = Color(0xFFE2E7EF);

  // ── Accents (theme-agnostic) ──
  static const Color accent = Color(0xFF00E5FF);
  static const Color green = Color(0xFF3DDB9A);
  static const Color amber = Color(0xFFF9C74F);
  static const Color red = Color(0xFFFF7B72);
  static const Color gold = Color(0xFFD4AF37);

  // ── Text (dark) ──
  static const Color text = Color(0xFFF2F6FB);
  static const Color textSecondary = Color(0xFF9BA8BD);
  static const Color textTertiary = Color(0xFF5C6B82);

  // ── Text (light) ──
  static const Color textLight = Color(0xFF0E1422);
  static const Color textSecondaryLight = Color(0xFF55617A);
  static const Color textTertiaryLight = Color(0xFF8A95A8);

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final tt = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: text, displayColor: text);

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
          letterSpacing: -0.6,
          fontFeatures: kTabularNumerals,
        ),
        titleLarge: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          fontFeatures: kTabularNumerals,
        ),
        titleMedium: tt.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: kTabularNumerals,
        ),
        bodyMedium: tt.bodyMedium?.copyWith(
          color: textSecondary,
          height: 1.55,
          fontFeatures: kTabularNumerals,
        ),
        bodySmall: tt.bodySmall?.copyWith(
          color: textTertiary,
          fontSize: 12,
          fontFeatures: kTabularNumerals,
        ),
        labelLarge: tt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontFeatures: kTabularNumerals,
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
          borderRadius: const BorderRadius.all(Radius.circular(Radii.lg)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          return IconThemeData(color: sel ? accent : textTertiary, size: 22);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
    final tt = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: textLight, displayColor: textLight);
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
          letterSpacing: -0.6,
          fontFeatures: kTabularNumerals,
        ),
        titleLarge: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          fontFeatures: kTabularNumerals,
        ),
        titleMedium: tt.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: kTabularNumerals,
        ),
        bodyMedium: tt.bodyMedium?.copyWith(
          color: textSecondaryLight,
          height: 1.55,
          fontFeatures: kTabularNumerals,
        ),
        bodySmall: tt.bodySmall?.copyWith(
          color: textTertiaryLight,
          fontSize: 12,
          fontFeatures: kTabularNumerals,
        ),
        labelLarge: tt.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontFeatures: kTabularNumerals,
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
          borderRadius: const BorderRadius.all(Radius.circular(Radii.lg)),
          side: const BorderSide(color: borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaisedLight,
        labelStyle: const TextStyle(color: textSecondaryLight),
        hintStyle: const TextStyle(color: textTertiaryLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textLight,
          side: const BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
