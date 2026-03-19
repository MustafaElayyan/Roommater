import '../repositories/auth_repository.dart';

/// Use case: send a password reset email to a user.
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.resetPassword(email: email);
  }
}
