import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pure-black minimalist design system.
class AppTheme {
  // ── Surfaces ──
  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceRaised = Color(0xFF141414);
  static const Color border = Color(0xFF1E1E1E);

  // ── Accents ──
  static const Color accent = Color(0xFF00E5FF);
  static const Color green = Color(0xFF00E676);
  static const Color amber = Color(0xFFFFD740);
  static const Color red = Color(0xFFFF5252);

  // ── Text ──
  static const Color text = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF555555);

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final tt = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: text,
      displayColor: text,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
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
}
