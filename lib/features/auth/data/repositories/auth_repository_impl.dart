import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository] backed by the API datasource.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _dataSource.signIn(email: email, password: password);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to sign in.', e);
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      return await _dataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to sign up.', e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to sign out.', e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _dataSource.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to send password reset email.', e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _dataSource.sendEmailVerification();
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to send verification email.', e);
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    try {
      await _dataSource.resendEmailVerification();
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to resend verification email.', e);
    }
  }

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      await _dataSource.updateProfilePhoto(photoUrl);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthException('Failed to update profile photo.', e);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;

  @override
  void dispose() {}
}
