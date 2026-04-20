import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../controllers/profile_controller.dart';

class ProfileDetailsScreen extends ConsumerWidget {
  const ProfileDetailsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.home);
          },
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load profile: $error')),
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: UserAvatar(
                  photoUrl: profile.photoUrl,
                  displayName: profile.displayName,
                  radius: 44,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  profile.bio!.trim(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              _infoTile(context, 'Email', profile.email),
              _infoTile(context, 'Phone', profile.phone),
              _infoTile(context, 'Occupation', profile.occupation),
              _infoTile(context, 'Location', profile.location),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(BuildContext context, String label, String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(trimmed),
    );
  }
}
