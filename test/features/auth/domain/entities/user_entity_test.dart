import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/features/auth/domain/entities/user_entity.dart';

void main() {
  test('two UserEntity instances with same uid are equal', () {
    const first = UserEntity(uid: 'u1', email: 'first@example.com');
    const second = UserEntity(uid: 'u1', email: 'second@example.com');

    expect(first, equals(second));
  });

  test('two UserEntity instances with different uid are not equal', () {
    const first = UserEntity(uid: 'u1', email: 'user@example.com');
    const second = UserEntity(uid: 'u2', email: 'user@example.com');

    expect(first, isNot(equals(second)));
  });

  test('hashCode is derived from uid', () {
    const user = UserEntity(uid: 'u1', email: 'user@example.com');

    expect(user.hashCode, 'u1'.hashCode);
  });
}
