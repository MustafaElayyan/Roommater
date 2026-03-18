import '../../../../core/errors/app_exception.dart';
import '../../../../core/local/local_store.dart';
import '../models/user_model.dart';

/// Performs auth calls against local in-memory state and translates errors into
/// [AuthException] so that repository implementations stay exception-safe.
class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final account = LocalStore.accountsByEmail[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Invalid email or password.');
    }
    final user = UserModel.fromAuthData(uid: account.uid, email: account.email);
    LocalStore.currentUser = user;
    LocalStore.authStateController.add(user);
    return user;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (LocalStore.accountsByEmail.containsKey(normalizedEmail)) {
      throw const AuthException('Email is already in use.');
    }
    if (password.length < 6) {
      throw const AuthException('Password should be at least 6 characters.');
    }
    final user = UserModel.fromAuthData(
      uid: LocalStore.nextId('user'),
      email: normalizedEmail,
    );
    LocalStore.accountsByEmail[normalizedEmail] = LocalAuthAccount(
      uid: user.uid,
      email: user.email,
      password: password,
    );
    LocalStore.currentUser = user;
    LocalStore.authStateController.add(user);
    return user;
  }

  Future<void> signOut() async {
    LocalStore.currentUser = null;
    LocalStore.authStateController.add(null);
  }

  Stream<UserModel?> get authStateChanges {
    return Stream<UserModel?>.multi((controller) {
      controller.add(LocalStore.currentUser);
      final sub = LocalStore.authStateController.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = sub.cancel;
    });
  }
}
