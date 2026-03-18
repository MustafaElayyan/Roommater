import '../repositories/auth_repository.dart';

/// Use case: sign out the currently authenticated user.
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
