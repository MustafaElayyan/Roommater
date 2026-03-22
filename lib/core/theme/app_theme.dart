import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Defines the light and dark [ThemeData] used by [MaterialApp.router].
///
/// All theme customisation should be centralised here so that UI components
/// pick up changes automatically without modification.
abstract final class AppTheme {
  static const BorderRadius _inputBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const OutlineInputBorder _lightDefaultInputBorder = OutlineInputBorder(
    borderRadius: _inputBorderRadius,
    borderSide: BorderSide(
      color: AppColors.textPrimary,
      width: 1.2,
    ),
  );
  static const OutlineInputBorder _darkDefaultInputBorder = OutlineInputBorder(
    borderRadius: _inputBorderRadius,
    borderSide: BorderSide(
      color: Colors.white,
      width: 1.2,
    ),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: _lightDefaultInputBorder,
          enabledBorder: _lightDefaultInputBorder,
          labelStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: Color(0x9913524A),
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primaryDark,
          onPrimary: AppColors.textOnPrimary,
          surface: AppColors.surfaceDark,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: _darkDefaultInputBorder,
          enabledBorder: _darkDefaultInputBorder,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: _inputBorderRadius,
            borderSide: BorderSide(
              color: Color(0x99FFFFFF),
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
