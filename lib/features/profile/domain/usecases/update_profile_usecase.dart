import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case: persist updates to a user's profile.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call(ProfileEntity profile) =>
      _repository.updateProfile(profile);
}
