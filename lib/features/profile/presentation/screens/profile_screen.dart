import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/profile_entity.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const int _minPasswordLength = 8;
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _occupationController = TextEditingController();
  final _locationController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _picker = ImagePicker();
  bool _didInitControllers = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _locationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage(String uid) async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final extension = image.path.contains('.') ? image.path.split('.').last.toLowerCase() : 'jpg';
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await ref.read(profileControllerProvider.notifier).updateProfilePhoto(
          uid: uid,
          bytes: bytes,
          extension: extension,
          contentType: contentType,
        );
    if (!mounted) return;
    final state = ref.read(profileControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
    } else {
      ref.invalidate(profileProvider(uid));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated.')),
      );
    }
  }

  Future<void> _saveProfile(ProfileEntity current) async {
    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name is required.')),
      );
      return;
    }
    await ref.read(profileControllerProvider.notifier).updateProfile(
          ProfileEntity(
            uid: current.uid,
            displayName: displayName,
            email: current.email,
            bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            photoUrl: current.photoUrl,
            age: current.age,
            occupation: _occupationController.text.trim().isEmpty
                ? null
                : _occupationController.text.trim(),
            location:
                _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          ),
        );
    if (!mounted) return;
    final state = ref.read(profileControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
      return;
    }
    ref.invalidate(profileProvider(current.uid));
    final authUser = ref.read(firebaseAuthProvider).currentUser;
    if (authUser != null && authUser.uid == current.uid) {
      await authUser.updateDisplayName(displayName);
      await ref.refresh(authStateProvider.future);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated.')),
    );
  }

  Future<void> _changePassword(String email) async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    if (currentPassword.isEmpty || newPassword.length < _minPasswordLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter current password and new password (min 8 chars).')),
      );
      return;
    }
    await ref.read(profileControllerProvider.notifier).changePassword(
          email: email,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
    if (!mounted) return;
    final state = ref.read(profileControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
      return;
    }
    _currentPasswordController.clear();
    _newPasswordController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please sign in.')),
      );
    }
    final profileAsync = ref.watch(profileProvider(user.uid));
    final isSubmitting = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load profile: $error')),
        data: (profile) {
          if (!_didInitControllers) {
            _displayNameController.text = profile.displayName;
            _phoneController.text = profile.phone ?? '';
            _bioController.text = profile.bio ?? '';
            _occupationController.text = profile.occupation ?? '';
            _locationController.text = profile.location ?? '';
            _didInitControllers = true;
          }

          final hasPhoto = profile.photoUrl?.isNotEmpty ?? false;
          final fallbackLetter = profile.displayName.isNotEmpty
              ? profile.displayName[0].toUpperCase()
              : '?';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: hasPhoto ? NetworkImage(profile.photoUrl!) : null,
                      child: hasPhoto ? null : Text(fallbackLetter),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 16,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: isSubmitting ? null : () => _pickProfileImage(profile.uid),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _occupationController,
                decoration: const InputDecoration(labelText: 'Occupation'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isSubmitting ? null : () => _saveProfile(profile),
                child: const Text('Save Profile'),
              ),
              const SizedBox(height: 24),
              Text('Change Password', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: isSubmitting ? null : () => _changePassword(profile.email),
                child: const Text('Update Password'),
              ),
            ],
          );
        },
      ),
    );
  }
}
