import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../household/presentation/controllers/household_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  final _householdNameController = TextEditingController();
  String? _boundHouseholdId;

  @override
  void dispose() {
    _householdNameController.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final household = ref.watch(currentHouseholdProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final isOwner = household != null && user?.uid == household.createdByUserId;
    final isHouseholdSubmitting = ref.watch(householdControllerProvider).isLoading;
    if (household != null && _boundHouseholdId != household.id) {
      _boundHouseholdId = household.id;
      _householdNameController.text = household.name;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile Settings'),
              onTap: () => context.push(AppRoutes.profile),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Update Password'),
              onTap: () => context.push(AppRoutes.updatePassword),
            ),
            SwitchListTile(
              value: isDarkMode,
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
              title: const Text('Dark Mode'),
            ),
            SwitchListTile(
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
              title: const Text('Push Notifications'),
            ),
            const Divider(),
            const ListTile(
              title: Text(
                'Household',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (household == null)
              const ListTile(
                leading: Icon(Icons.house_outlined),
                title: Text('No household selected'),
              )
            else ...[
              if (isOwner) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _householdNameController,
                    decoration: const InputDecoration(
                      labelText: 'Household Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: FilledButton(
                    onPressed: isHouseholdSubmitting
                        ? null
                        : () async {
                            final updatedName = _householdNameController.text.trim();
                            if (updatedName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Household name cannot be empty.'),
                                ),
                              );
                              return;
                            }
                            await ref
                                .read(householdControllerProvider.notifier)
                                .updateHouseholdName(
                                  householdId: household.id,
                                  name: updatedName,
                                );
                            if (!context.mounted) return;
                            final state = ref.read(householdControllerProvider);
                            if (state.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error.toString())),
                              );
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Household name updated.')),
                            );
                          },
                    child: const Text('Save Household Name'),
                  ),
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.house_outlined),
                  title: const Text('Household Name'),
                  subtitle: Text(household.name),
                ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(isOwner ? 'Manage Members' : 'View Members'),
                onTap: () => context.push(AppRoutes.manageMembers),
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: const Text('Household Code'),
                subtitle: Text(
                  household.inviteCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: household.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Household code copied!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Leave Household'),
                onTap: () async {
                  final shouldLeave = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Leave Household'),
                      content: const Text(
                        'Are you sure you want to leave this household?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Leave'),
                        ),
                      ],
                    ),
                  );
                  if (shouldLeave != true) return;
                  await ref
                      .read(householdControllerProvider.notifier)
                      .leaveHousehold(household.id);
                  if (!context.mounted) return;
                  final state = ref.read(householdControllerProvider);
                  if (state.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error.toString())),
                    );
                    return;
                  }
                  context.go(AppRoutes.noHousehold);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
