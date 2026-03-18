import '../entities/profile_entity.dart';

/// Contract for profile read/write operations.
abstract interface class ProfileRepository {
  /// Returns the profile for [uid].
  Future<ProfileEntity> getProfile(String uid);

  /// Persists changes to a user's profile.
  Future<ProfileEntity> updateProfile(ProfileEntity profile);
}
