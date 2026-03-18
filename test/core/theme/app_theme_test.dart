import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/core/theme/app_theme.dart';

void main() {
  test('light theme uses camel scaffold background', () {
    expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFFC19A6B));
  });
}
