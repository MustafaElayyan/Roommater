import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: sign in an existing user with email and password.
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
