import '../repositories/profile_repository.dart';

class UpdateProfilePhotoUseCase {
  const UpdateProfilePhotoUseCase(this._repository);

  final ProfileRepository _repository;

  Future<String> call({
    required String uid,
    required List<int> bytes,
    required String extension,
    required String contentType,
  }) {
    return _repository.updateProfilePhoto(
      uid: uid,
      bytes: bytes,
      extension: extension,
      contentType: contentType,
    );
  }
}
