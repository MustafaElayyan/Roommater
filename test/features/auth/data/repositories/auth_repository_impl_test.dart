import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roommater/core/errors/app_exception.dart';
import 'package:roommater/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:roommater/features/auth/data/models/user_model.dart';
import 'package:roommater/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:roommater/features/auth/domain/entities/user_entity.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late _MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('signIn', () {
    test('delegates to datasource and returns UserEntity', () async {
      const model = UserModel(uid: 'u1', email: 'user@example.com');
      when(
        () => dataSource.signIn(email: 'user@example.com', password: 'password'),
      ).thenAnswer((_) async => model);

      final result = await repository.signIn(
        email: 'user@example.com',
        password: 'password',
      );

      expect(result, model);
      verify(
        () => dataSource.signIn(email: 'user@example.com', password: 'password'),
      ).called(1);
    });

    test('rethrows AuthException from datasource', () async {
      when(
        () => dataSource.signIn(email: 'user@example.com', password: 'password'),
      ).thenThrow(const AuthException('nope'));

      expect(
        () => repository.signIn(email: 'user@example.com', password: 'password'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signUp', () {
    test('delegates to datasource and returns UserEntity', () async {
      const model = UserModel(uid: 'u1', email: 'user@example.com');
      when(
        () => dataSource.signUp(email: 'user@example.com', password: 'password'),
      ).thenAnswer((_) async => model);

      final result = await repository.signUp(
        email: 'user@example.com',
        password: 'password',
      );

      expect(result, model);
      verify(
        () => dataSource.signUp(email: 'user@example.com', password: 'password'),
      ).called(1);
    });

    test('rethrows AuthException from datasource', () async {
      when(
        () => dataSource.signUp(email: 'user@example.com', password: 'password'),
      ).thenThrow(const AuthException('nope'));

      expect(
        () => repository.signUp(email: 'user@example.com', password: 'password'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signOut', () {
    test('delegates to datasource', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => dataSource.signOut()).called(1);
    });

    test('rethrows AuthException from datasource', () async {
      when(() => dataSource.signOut()).thenThrow(const AuthException('nope'));

      expect(() => repository.signOut(), throwsA(isA<AuthException>()));
    });
  });

  group('authStateChanges', () {
    test('forwards datasource stream', () async {
      final controller = StreamController<UserModel?>();
      when(() => dataSource.authStateChanges).thenAnswer((_) => controller.stream);

      final emitted = <UserEntity?>[];
      final sub = repository.authStateChanges.listen(emitted.add);

      controller
        ..add(const UserModel(uid: 'u1', email: 'user@example.com'))
        ..add(null);
      await controller.close();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.map((e) => e?.uid), ['u1', null]);
    });
  });
}
