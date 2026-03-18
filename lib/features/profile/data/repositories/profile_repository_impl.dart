import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

/// Local-data implementation of [ProfileRepository].
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
        photoUrl: profile.photoUrl,
        age: profile.age,
        occupation: profile.occupation,
        location: profile.location,
      ),
    );
  }
}
