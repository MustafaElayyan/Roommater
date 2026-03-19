import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roommater/core/constants/app_constants.dart';
import 'package:roommater/core/errors/app_exception.dart';
import 'package:roommater/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:roommater/features/auth/data/models/user_model.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockFirebaseAuth firebaseAuth;
  late _MockFirebaseFirestore firestore;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    firebaseAuth = _MockFirebaseAuth();
    firestore = _MockFirebaseFirestore();
    dataSource = AuthRemoteDataSource(firebaseAuth, firestore);
  });

  group('signIn', () {
    test('returns UserModel on success', () async {
      final credential = _MockUserCredential();
      final user = _MockUser();
      when(() => credential.user).thenReturn(user);
      when(() => user.uid).thenReturn('u1');
      when(() => user.email).thenReturn('user@example.com');
      when(() => user.displayName).thenReturn('User');
      when(() => user.photoURL).thenReturn('https://example.com/p.png');
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => credential);

      final result = await dataSource.signIn(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result, isA<UserModel>());
      expect(result.uid, 'u1');
      expect(result.email, 'user@example.com');
    });

    test('throws AuthException when FirebaseAuthException occurs', () async {
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ),
      );

      expect(
        () => dataSource.signIn(
          email: 'user@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signUp', () {
    test('returns UserModel and writes firestore document on success', () async {
      final credential = _MockUserCredential();
      final user = _MockUser();
      final usersCollection = _MockCollectionReference();
      final docRef = _MockDocumentReference();

      when(() => credential.user).thenReturn(user);
      when(() => user.uid).thenReturn('u1');
      when(() => user.email).thenReturn('user@example.com');
      when(() => user.displayName).thenReturn('User');
      when(() => user.photoURL).thenReturn('https://example.com/p.png');
      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => credential);
      when(
        () => firestore.collection(AppConstants.usersCollection),
      ).thenReturn(usersCollection);
      when(() => usersCollection.doc('u1')).thenReturn(docRef);
      when(
        () => docRef.set({
          'uid': 'u1',
          'email': 'user@example.com',
          'displayName': 'User',
          'photoUrl': 'https://example.com/p.png',
        }),
      ).thenAnswer((_) async {});

      final result = await dataSource.signUp(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result, isA<UserModel>());
      verify(
        () => firestore.collection(AppConstants.usersCollection),
      ).called(1);
      verify(() => usersCollection.doc('u1')).called(1);
      verify(
        () => docRef.set({
          'uid': 'u1',
          'email': 'user@example.com',
          'displayName': 'User',
          'photoUrl': 'https://example.com/p.png',
        }),
      ).called(1);
    });

    test('throws AuthException when FirebaseAuthException occurs', () async {
      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already used',
        ),
      );

      expect(
        () => dataSource.signUp(
          email: 'user@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('signOut', () {
    test('completes successfully', () async {
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(() => firebaseAuth.signOut()).called(1);
    });

    test('throws AuthException when FirebaseAuthException occurs', () async {
      when(() => firebaseAuth.signOut()).thenThrow(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      expect(() => dataSource.signOut(), throwsA(isA<AuthException>()));
    });
  });

  group('authStateChanges', () {
    test('maps Firebase user stream to UserModel? stream', () async {
      final controller = StreamController<User?>();
      final user = _MockUser();

      when(() => firebaseAuth.authStateChanges()).thenAnswer(
        (_) => controller.stream,
      );
      when(() => user.uid).thenReturn('u1');
      when(() => user.email).thenReturn('user@example.com');
      when(() => user.displayName).thenReturn('User');
      when(() => user.photoURL).thenReturn(null);

      final emitted = <UserModel?>[];
      final sub = dataSource.authStateChanges.listen(emitted.add);

      controller.add(user);
      controller.add(null);
      await controller.close();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.length, 2);
      expect(emitted.first, isA<UserModel>());
      expect(emitted.first?.uid, 'u1');
      expect(emitted.last, isNull);
    });
  });
}
