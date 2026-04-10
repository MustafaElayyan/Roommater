import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Performs Firebase Auth/Firestore calls and translates failures into [AuthException].
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No Firebase user returned after sign-in.');
      }
      return _readOrCreateUserDocument(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign in.', e);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign in.', e);
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No Firebase user returned after sign-up.');
      }
      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        await user.updateDisplayName(trimmedDisplayName);
      }
      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'uid': user.uid,
        'email': user.email ?? email,
        'displayName':
            trimmedDisplayName == null || trimmedDisplayName.isEmpty
                ? null
                : trimmedDisplayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.sendEmailVerification();
      final doc = await userDoc.get();
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign up.', e);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign up.', e);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign out.', e);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign out.', e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email.', e);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email.', e);
    }
  }

  Future<void> sendEmailVerification() async {
    await _sendVerificationEmail(
      errorMessage: 'Failed to send verification email.',
    );
  }

  Future<void> resendEmailVerification() async {
    await _sendVerificationEmail(
      errorMessage: 'Failed to resend verification email.',
    );
  }

  Future<void> _sendVerificationEmail({
    required String errorMessage,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found.');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? errorMessage, e);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? errorMessage, e);
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found.');
      }
      await user.updatePhotoURL(photoUrl);
      await _firestore.collection('users').doc(user.uid).set({
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to update profile photo.', e);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to update profile photo.', e);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return _readOrCreateUserDocument(user);
    } on FirebaseException {
      return null;
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _readOrCreateUserDocument(user);
    });
  }

  Future<UserModel> _readOrCreateUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();
    if (doc.exists) return UserModel.fromFirestore(doc);

    final fallback = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      householdId: null,
    );
    await userDoc.set(fallback.toFirestore(), SetOptions(merge: true));
    final created = await userDoc.get();
    return UserModel.fromFirestore(created);
  }
}
