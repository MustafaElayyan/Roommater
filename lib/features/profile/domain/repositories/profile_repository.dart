import '../entities/profile_entity.dart';

/// Contract for profile read/write operations.
abstract interface class ProfileRepository {
  /// Returns the profile for [uid].
  Future<ProfileEntity> getProfile(String uid);

  /// Persists changes to a user's profile.
  Future<ProfileEntity> updateProfile(ProfileEntity profile);

  Future<String> updateProfilePhoto({
    required String uid,
    required List<int> bytes,
    required String extension,
    required String contentType,
  });

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  });
}
