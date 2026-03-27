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
  UserEntity? _currentUser;
  bool _isHydrated = false;
  bool _isDisposed = false;

  StreamController<UserEntity?> get _controller {
    _ensureNotDisposed();
    return _authStateController ??= StreamController<UserEntity?>.broadcast();
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('AuthRepositoryImpl has been disposed.');
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    _ensureNotDisposed();
    try {
      final user = await _dataSource.signIn(email: email, password: password);
      _currentUser = user;
      _isHydrated = true;
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
    _ensureNotDisposed();
    try {
      final user = await _dataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _currentUser = user;
      _isHydrated = true;
      _controller.add(user);
      return user;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    _ensureNotDisposed();
    try {
      await _dataSource.signOut();
      _currentUser = null;
      _isHydrated = true;
      _controller.add(_currentUser);
    } on AuthException {
      rethrow;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges async* {
    _ensureNotDisposed();
    if (!_isHydrated) {
      final currentUser = await _dataSource.getCurrentUser();
      if (_isDisposed) return;
      _currentUser = currentUser;
      _isHydrated = true;
    }
    if (_isDisposed) return;
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _authStateController?.close();
    _authStateController = null;
    _currentUser = null;
    _isHydrated = false;
  }
}
