import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';

/// In-memory implementation of [SettingsRepository].
///
/// Replace with a `shared_preferences`-backed implementation when persistent
/// settings storage is required.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsModel _current = const SettingsModel();

  @override
  Future<SettingsEntity> getSettings() async => _current;

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    _current = SettingsModel(
      isDarkMode: settings.isDarkMode,
      notificationsEnabled: settings.notificationsEnabled,
      locale: settings.locale,
    );
  }
}
