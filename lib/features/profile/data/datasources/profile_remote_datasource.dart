import '../../../../core/errors/app_exception.dart';
import '../../../../core/local/local_store.dart';
import '../models/profile_model.dart';

/// Handles local reads/writes for user profiles.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource();

  Future<ProfileModel> getProfile(String uid) async {
    try {
      final existing = LocalStore.profilesById[uid];
      if (existing != null) return existing;

      final fallback = ProfileModel(
        uid: uid,
        displayName: 'Roommater User',
        email: '$uid@roommater.local',
      );
      LocalStore.profilesById[uid] = fallback;
      return fallback;
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to load profile.', e);
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      LocalStore.profilesById[profile.uid] = profile;
      return profile;
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to update profile.', e);
    }
  }
}
