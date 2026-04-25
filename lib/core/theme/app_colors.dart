import 'package:flutter/material.dart';

/// Roommater brand color palette.
///
/// Use only these constants throughout the app to ensure visual consistency.
abstract final class AppColors {
  // Primary brand colours
  static const Color primary = Color(0xFF1D7B6F);
  static const Color primaryDark = Color(0xFF13524A);
  static const Color primaryLight = Color(0xFF23967F);

  // Accent
  static const Color accent = Color(0xFF23967F);

  // Neutral
  static const Color backgroundLight = Color(0xFFF0F5F5);
  static const Color backgroundDark = Color(0xFF081418);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF112126);

  // Text
  static const Color textPrimary = Color(0xFF0E2E29);
  static const Color textSecondary = Color(0xFF13524A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
}
