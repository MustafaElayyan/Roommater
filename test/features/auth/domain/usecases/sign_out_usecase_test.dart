import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roommater/features/auth/domain/repositories/auth_repository.dart';
import 'package:roommater/features/auth/domain/usecases/sign_out_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SignOutUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = SignOutUseCase(repository);
  });

  test('calls repository.signOut', () async {
    when(() => repository.signOut()).thenAnswer((_) async {});

    await useCase();

    verify(() => repository.signOut()).called(1);
  });

  test('throws when repository throws', () async {
    when(() => repository.signOut()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsA(isA<Exception>()));
  });
}
