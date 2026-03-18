import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/settings_entity.dart';
import '../controllers/settings_controller.dart';

/// Allows users to toggle app-wide preferences such as dark mode and
/// notifications.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settings.isDarkMode,
              onChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .updateSettings(
                    SettingsEntity(
                      isDarkMode: value,
                      notificationsEnabled: settings.notificationsEnabled,
                      locale: settings.locale,
                    ),
                  ),
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: settings.notificationsEnabled,
              onChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .updateSettings(
                    SettingsEntity(
                      isDarkMode: settings.isDarkMode,
                      notificationsEnabled: value,
                      locale: settings.locale,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
