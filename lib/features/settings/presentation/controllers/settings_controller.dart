import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

// --- Dependency graph ---

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

// --- Controller ---

class SettingsController extends AsyncNotifier<SettingsEntity> {
  @override
  Future<SettingsEntity> build() async {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateSettings(SettingsEntity settings) async {
    state = const AsyncLoading();
    await ref.read(settingsRepositoryProvider).saveSettings(settings);
    state = AsyncData(settings);
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsEntity>(
  SettingsController.new,
);
