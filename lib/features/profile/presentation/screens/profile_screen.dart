import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final displayName = user?.displayName?.trim();
    final hasName = displayName != null && displayName.isNotEmpty;
    final hasPhoto = user?.photoUrl?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundImage: hasPhoto ? NetworkImage(user!.photoUrl!) : null,
              child: hasPhoto
                  ? null
                  : Text(
                      hasName ? displayName![0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              hasName ? displayName! : 'No display name set',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(user?.email ?? 'No email available')),
        ],
      ),
    );
  }
}
