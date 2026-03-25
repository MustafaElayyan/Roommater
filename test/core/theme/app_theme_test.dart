import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/core/theme/app_colors.dart';
import 'package:roommater/core/theme/app_theme.dart';

void main() {
  test('light and dark themes use updated teal scaffold backgrounds', () {
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.backgroundLight);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.backgroundDark);
  });

  test('elevated buttons use brand CTA color in both themes', () {
    final lightStyle = AppTheme.light.elevatedButtonTheme.style;
    final darkStyle = AppTheme.dark.elevatedButtonTheme.style;

    expect(
      lightStyle?.backgroundColor?.resolve(<WidgetState>{}),
      AppColors.primaryLight,
    );
    expect(
      darkStyle?.backgroundColor?.resolve(<WidgetState>{}),
      AppColors.primaryLight,
    );
  });

  test('light theme keeps visible input borders across states', () {
    final inputTheme = AppTheme.light.inputDecorationTheme;
    final enabledBorder = inputTheme.enabledBorder as OutlineInputBorder?;
    final focusedBorder = inputTheme.focusedBorder as OutlineInputBorder?;
    final errorBorder = inputTheme.errorBorder as OutlineInputBorder?;
    final disabledBorder = inputTheme.disabledBorder as OutlineInputBorder?;
    final labelStyle = inputTheme.labelStyle;
    final floatingLabelStyle = inputTheme.floatingLabelStyle;

    expect(enabledBorder, isNotNull);
    expect(focusedBorder, isNotNull);
    expect(errorBorder, isNotNull);
    expect(disabledBorder, isNotNull);

    expect(enabledBorder!.borderSide.color, AppColors.textPrimary);
    expect(enabledBorder.borderSide.width, greaterThan(0));
    expect(
      focusedBorder!.borderSide.width,
      greaterThan(enabledBorder.borderSide.width),
    );
    expect(errorBorder!.borderSide.color, AppColors.error);
    expect(errorBorder.borderSide.width, greaterThan(0));
    expect(disabledBorder!.borderSide.width, greaterThan(0));
    expect(disabledBorder.borderSide.color.alpha, greaterThan(0));
    expect(labelStyle?.color, AppColors.textPrimary);
    expect(labelStyle?.fontWeight, FontWeight.w600);
    expect(floatingLabelStyle?.color, AppColors.textPrimary);
    expect(floatingLabelStyle?.fontWeight, FontWeight.w700);
  });

  test('dark theme keeps visible input borders across states', () {
    final inputTheme = AppTheme.dark.inputDecorationTheme;
    final enabledBorder = inputTheme.enabledBorder as OutlineInputBorder?;
    final focusedBorder = inputTheme.focusedBorder as OutlineInputBorder?;
    final errorBorder = inputTheme.errorBorder as OutlineInputBorder?;
    final disabledBorder = inputTheme.disabledBorder as OutlineInputBorder?;
    final labelStyle = inputTheme.labelStyle;
    final floatingLabelStyle = inputTheme.floatingLabelStyle;

    expect(enabledBorder, isNotNull);
    expect(focusedBorder, isNotNull);
    expect(errorBorder, isNotNull);
    expect(disabledBorder, isNotNull);

    expect(enabledBorder!.borderSide.color, Colors.white);
    expect(enabledBorder.borderSide.width, greaterThan(0));
    expect(
      focusedBorder!.borderSide.width,
      greaterThan(enabledBorder.borderSide.width),
    );
    expect(errorBorder!.borderSide.color, AppColors.error);
    expect(errorBorder.borderSide.width, greaterThan(0));
    expect(disabledBorder!.borderSide.width, greaterThan(0));
    expect(disabledBorder.borderSide.color.alpha, greaterThan(0));
    expect(labelStyle?.color, Colors.white);
    expect(labelStyle?.fontWeight, FontWeight.w600);
    expect(floatingLabelStyle?.color, Colors.white);
    expect(floatingLabelStyle?.fontWeight, FontWeight.w700);
  });
}
