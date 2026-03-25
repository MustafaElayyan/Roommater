import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: register a new user account with email and password.
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
