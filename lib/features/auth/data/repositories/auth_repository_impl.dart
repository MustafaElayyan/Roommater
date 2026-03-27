import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'dart:async';

/// Concrete implementation of [AuthRepository] backed by the API datasource.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;
  final StreamController<UserEntity?> _authStateController =
      StreamController<UserEntity?>.broadcast();
  bool _isInitialized = false;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signIn(email: email, password: password);
      _authStateController.add(user);
      return user;
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
      final user = await _dataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _authStateController.add(user);
      return user;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
      _authStateController.add(null);
    } on AuthException {
      rethrow;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges async* {
    if (!_isInitialized) {
      _isInitialized = true;
      yield await _dataSource.getCurrentUser();
    }
    yield* _authStateController.stream;
  }
}
