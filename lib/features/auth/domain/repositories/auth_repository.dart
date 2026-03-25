import '../entities/user_entity.dart';

/// Contract for authentication operations.
///
/// The data layer provides a concrete implementation; the domain layer only
/// depends on this abstract interface, enabling easy substitution in tests.
abstract interface class AuthRepository {
  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [UserEntity] on success, or throws an
  /// [AppException] on failure.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account with [email] and [password].
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Emits the currently authenticated user, or `null` when signed out.
  Stream<UserEntity?> get authStateChanges;
}
