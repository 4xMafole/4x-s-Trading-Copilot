import 'package:flutter/material.dart';

/// Design tokens — single source of truth for spacing, radii, motion, and
/// typographic features. Use these consts everywhere instead of literals.
class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class Radii {
  Radii._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 999;
}

/// Motion vocabulary — durations and curves used across the app.
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 380);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
}

/// Tabular numerals — used on every KPI / P&L digit so values don't jitter.
const List<FontFeature> kTabularNumerals = [FontFeature.tabularFigures()];
