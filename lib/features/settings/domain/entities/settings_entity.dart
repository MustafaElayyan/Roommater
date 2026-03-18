import 'package:flutter/foundation.dart';

/// Domain entity for user preferences/settings.
@immutable
class SettingsEntity {
  const SettingsEntity({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.locale = 'en',
  });

  final bool isDarkMode;
  final bool notificationsEnabled;
  final String locale;
}
