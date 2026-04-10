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
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _dataSource.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _dataSource.sendEmailVerification();
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    try {
      await _dataSource.resendEmailVerification();
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      await _dataSource.updateProfilePhoto(photoUrl);
    } on AuthException {
      rethrow;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;

  @override
  void dispose() {}
}
