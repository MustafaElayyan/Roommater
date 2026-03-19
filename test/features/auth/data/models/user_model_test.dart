import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/features/auth/data/models/user_model.dart';
import 'package:roommater/features/auth/domain/entities/user_entity.dart';

void main() {
  test('fromFirebase creates the expected model', () {
    final model = UserModel.fromFirebase(
      uid: 'u1',
      email: 'user@example.com',
      displayName: 'User',
      photoUrl: 'https://example.com/p.png',
    );

    expect(model.uid, 'u1');
    expect(model.email, 'user@example.com');
    expect(model.displayName, 'User');
    expect(model.photoUrl, 'https://example.com/p.png');
  });

  test('toFirestore only includes optional fields when non-null', () {
    const withOptionals = UserModel(
      uid: 'u1',
      email: 'user@example.com',
      displayName: 'User',
      photoUrl: 'https://example.com/p.png',
    );
    const withoutOptionals = UserModel(uid: 'u2', email: 'other@example.com');

    expect(withOptionals.toFirestore(), {
      'uid': 'u1',
      'email': 'user@example.com',
      'displayName': 'User',
      'photoUrl': 'https://example.com/p.png',
    });
    expect(withoutOptionals.toFirestore(), {
      'uid': 'u2',
      'email': 'other@example.com',
    });
  });

  test('fromFirestore parses data correctly', () {
    final model = UserModel.fromFirestore({
      'uid': 'u1',
      'email': 'user@example.com',
      'displayName': 'User',
      'photoUrl': 'https://example.com/p.png',
    });

    expect(model.uid, 'u1');
    expect(model.email, 'user@example.com');
    expect(model.displayName, 'User');
    expect(model.photoUrl, 'https://example.com/p.png');
  });

  test('fromFirestore(toFirestore()) round-trip preserves user identity', () {
    const model = UserModel(
      uid: 'u1',
      email: 'user@example.com',
      displayName: 'User',
      photoUrl: 'https://example.com/p.png',
    );

    final roundTrip = UserModel.fromFirestore(model.toFirestore());

    expect(roundTrip, equals(model));
    expect(roundTrip.toFirestore(), equals(model.toFirestore()));
  });

  test('UserModel is a UserEntity', () {
    const model = UserModel(uid: 'u1', email: 'user@example.com');

    expect(model, isA<UserEntity>());
  });
}
