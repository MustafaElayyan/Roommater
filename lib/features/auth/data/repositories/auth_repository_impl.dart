import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository] backed by the API datasource.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;
  StreamController<UserEntity?>? _authStateController;

  StreamController<UserEntity?> get _controller =>
      _authStateController ??= StreamController<UserEntity?>.broadcast();

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signIn(email: email, password: password);
      _controller.add(user);
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
      _controller.add(user);
      return user;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
      _controller.add(null);
    } on AuthException {
      rethrow;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges async* {
    yield await _dataSource.getCurrentUser();
    yield* _controller.stream;
  }

  @override
  void dispose() {
    _authStateController?.close();
    _authStateController = null;
  }
}
