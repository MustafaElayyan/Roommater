import 'package:flutter/material.dart';

/// Roommater brand color palette.
///
/// Use only these constants throughout the app to ensure visual consistency.
abstract final class AppColors {
  // Primary brand colours
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryDark = Color(0xFF2C6FAC);
  static const Color primaryLight = Color(0xFF7FB5E8);

  // Accent
  static const Color accent = Color(0xFFFF7043);

  // Neutral
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
}
