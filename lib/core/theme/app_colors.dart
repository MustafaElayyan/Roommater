import 'package:flutter/material.dart';

/// Roommater brand color palette.
///
/// Use only these constants throughout the app to ensure visual consistency.
abstract final class AppColors {
  // Primary brand colours
  static const Color primary = Color(0xFFC19A6B);
  static const Color primaryDark = Color(0xFF8B6B45);
  static const Color primaryLight = Color(0xFFD8BE9B);

  // Accent
  static const Color accent = Color(0xFFFF7043);

  // Neutral
  static const Color backgroundLight = Color(0xFFC19A6B);
  static const Color backgroundDark = Color(0xFFC19A6B);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF4D3924);

  // Text
  static const Color textPrimary = Color(0xFF2D2115);
  static const Color textSecondary = Color(0xFF4D3924);
  static const Color textOnPrimary = Color(0xFF1A130B);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
}
