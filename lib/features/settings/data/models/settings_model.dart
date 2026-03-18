import '../../domain/entities/settings_entity.dart';

/// Data-layer model for user settings (can map to shared_preferences or local storage).
class SettingsModel extends SettingsEntity {
  const SettingsModel({
    super.isDarkMode,
    super.notificationsEnabled,
    super.locale,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> data) {
    return SettingsModel(
      isDarkMode: data['isDarkMode'] as bool? ?? false,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      locale: data['locale'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'locale': locale,
    };
  }
}
