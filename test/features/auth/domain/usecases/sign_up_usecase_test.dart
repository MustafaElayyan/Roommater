import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roommater/features/auth/domain/entities/user_entity.dart';
import 'package:roommater/features/auth/domain/repositories/auth_repository.dart';
import 'package:roommater/features/auth/domain/usecases/sign_up_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SignUpUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = SignUpUseCase(repository);
  });

  test('delegates to repository.signUp with email and password', () async {
    const user = UserEntity(uid: 'u1', email: 'user@example.com');
    when(
      () => repository.signUp(email: 'user@example.com', password: 'password'),
    ).thenAnswer((_) async => user);

    final result = await useCase(
      email: 'user@example.com',
      password: 'password',
    );

    expect(result, user);
    verify(
      () => repository.signUp(email: 'user@example.com', password: 'password'),
    ).called(1);
  });

  test('throws when repository throws', () async {
    when(
      () => repository.signUp(email: 'user@example.com', password: 'password'),
    ).thenThrow(Exception('boom'));

    expect(
      () => useCase(email: 'user@example.com', password: 'password'),
      throwsA(isA<Exception>()),
    );
  });
}
