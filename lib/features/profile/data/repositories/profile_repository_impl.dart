import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

/// API-backed implementation of [ProfileRepository].
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileRemoteDataSource _dataSource;

  @override
  Future<ProfileEntity> getProfile(String uid) {
    return _dataSource.getProfile(uid);
  }

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity profile) {
    return _dataSource.updateProfile(
      ProfileModel(
        uid: profile.uid,
        displayName: profile.displayName,
        email: profile.email,
        bio: profile.bio,
        phone: profile.phone,
        photoUrl: profile.photoUrl,
        age: profile.age,
      ),
    );
  }

  @override
  Future<String> updateProfilePhoto({
    required String uid,
    required List<int> bytes,
    required String extension,
    required String contentType,
  }) {
    return _dataSource.updateProfilePhoto(
      uid: uid,
      bytes: bytes,
      extension: extension,
      contentType: contentType,
    );
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) {
    return _dataSource.changePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
