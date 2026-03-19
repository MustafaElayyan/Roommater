import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roommater/core/errors/app_exception.dart';
import 'package:roommater/features/auth/domain/entities/user_entity.dart';
import 'package:roommater/features/auth/domain/repositories/auth_repository.dart';
import 'package:roommater/features/auth/presentation/controllers/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late StreamController<UserEntity?> authStateController;
  late ProviderContainer container;

  setUp(() {
    repository = _MockAuthRepository();
    authStateController = StreamController<UserEntity?>();
    when(() => repository.authStateChanges).thenAnswer(
      (_) => authStateController.stream,
    );
    when(
      () => repository.resetPassword(email: any(named: 'email')),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    await authStateController.close();
    container.dispose();
  });

  group('AuthController', () {
    test('signIn success: state goes AsyncLoading -> AsyncData', () async {
      when(
        () => repository.signIn(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenAnswer(
        (_) async => const UserEntity(uid: 'u1', email: 'user@example.com'),
      );

      final states = <AsyncValue<void>>[];
      final sub = container.listen<AsyncValue<void>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).signIn(
            email: 'user@example.com',
            password: 'password123',
          );

      expect(states.any((s) => s is AsyncLoading<void>), isTrue);
      expect(states.last, isA<AsyncData<void>>());
      sub.close();
    });

    test('signIn failure: state goes AsyncLoading -> AsyncError', () async {
      when(
        () => repository.signIn(
          email: 'user@example.com',
          password: 'wrong-password',
        ),
      ).thenThrow(const AuthException('Invalid credentials'));

      final states = <AsyncValue<void>>[];
      final sub = container.listen<AsyncValue<void>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).signIn(
            email: 'user@example.com',
            password: 'wrong-password',
          );

      expect(states.any((s) => s is AsyncLoading<void>), isTrue);
      expect(states.last, isA<AsyncError<void>>());
      sub.close();
    });

    test('signUp success: state goes AsyncLoading -> AsyncData', () async {
      when(
        () => repository.signUp(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenAnswer(
        (_) async => const UserEntity(uid: 'u1', email: 'user@example.com'),
      );

      final states = <AsyncValue<void>>[];
      final sub = container.listen<AsyncValue<void>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).signUp(
            email: 'user@example.com',
            password: 'password123',
          );

      expect(states.any((s) => s is AsyncLoading<void>), isTrue);
      expect(states.last, isA<AsyncData<void>>());
      sub.close();
    });

    test('signUp failure: state goes AsyncLoading -> AsyncError', () async {
      when(
        () => repository.signUp(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenThrow(const AuthException('Email already used'));

      final states = <AsyncValue<void>>[];
      final sub = container.listen<AsyncValue<void>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).signUp(
            email: 'user@example.com',
            password: 'password123',
          );

      expect(states.any((s) => s is AsyncLoading<void>), isTrue);
      expect(states.last, isA<AsyncError<void>>());
      sub.close();
    });

    test('signOut success: state goes AsyncLoading -> AsyncData', () async {
      when(() => repository.signOut()).thenAnswer((_) async {});

      final states = <AsyncValue<void>>[];
      final sub = container.listen<AsyncValue<void>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).signOut();

      expect(states.any((s) => s is AsyncLoading<void>), isTrue);
      expect(states.last, isA<AsyncData<void>>());
      sub.close();
    });

    test('signOut failure: state goes AsyncLoading -> AsyncError', () async {
      when(() => repository.signOut()).thenThrow(const AuthException('No user'));

      final states = <AsyncValue<void>>[];
      final sub = container.listen<AsyncValue<void>>(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).signOut();

      expect(states.any((s) => s is AsyncLoading<void>), isTrue);
      expect(states.last, isA<AsyncError<void>>());
      sub.close();
    });
  });

  test('authStateProvider emits UserEntity then null', () async {
    final states = <AsyncValue<UserEntity?>>[];
    final sub = container.listen<AsyncValue<UserEntity?>>(
      authStateProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );

    authStateController
      ..add(const UserEntity(uid: 'u1', email: 'user@example.com'))
      ..add(null);
    await Future<void>.delayed(Duration.zero);

    expect(
      states.any(
        (s) => s is AsyncData<UserEntity?> && s.valueOrNull?.uid == 'u1',
      ),
      isTrue,
    );
    expect(
      states.any((s) => s is AsyncData<UserEntity?> && s.valueOrNull == null),
      isTrue,
    );
    sub.close();
  });
}
