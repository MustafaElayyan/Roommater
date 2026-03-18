import '../entities/settings_entity.dart';

/// Contract for reading and persisting user settings.
abstract interface class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveSettings(SettingsEntity settings);
}
