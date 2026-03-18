import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case: fetch a user's profile.
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call(String uid) => _repository.getProfile(uid);
}
