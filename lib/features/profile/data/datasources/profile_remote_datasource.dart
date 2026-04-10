import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/profile_model.dart';

/// Handles profile Firestore reads/writes.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(
    this._firestore,
    this._firebaseAuth,
    this._firebaseStorage,
  );

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

  Future<ProfileModel> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw const ApiException('Profile not found.');
      }
      return ProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load profile.', e);
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final docRef = _firestore.collection('users').doc(profile.uid);
      await docRef.set(profile.toFirestore(), SetOptions(merge: true));
      final updated = await docRef.get();
      return ProfileModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update profile.', e);
    }
  }

  Future<String> updateProfilePhoto({
    required String uid,
    required List<int> bytes,
    required String extension,
    required String contentType,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child('avatars/$uid.$extension');
      await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: contentType),
      );
      final photoUrl = await _getDownloadUrlWithRetry(ref);
      final userDoc = _firestore.collection('users').doc(uid);
      await userDoc.set({
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await userDoc.set({
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == uid) {
        await user.updatePhotoURL(photoUrl);
      }
      return photoUrl;
    } on FirebaseException catch (e) {
      throw ApiException(e.message ?? 'Failed to update profile photo.', e);
    } on Exception catch (e) {
      throw ApiException('Failed to update profile photo.', e);
    }
  }

  Future<String> _getDownloadUrlWithRetry(
    Reference ref, {
    int maxAttempts = 3,
  }) async {
    FirebaseException? objectNotFoundError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        if (e.code != 'object-not-found') {
          rethrow;
        }
        objectNotFoundError = e;
        if (attempt < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
        }
      }
    }
    throw ApiException(
      objectNotFoundError?.message ?? 'Failed to retrieve download URL for profile photo.',
      objectNotFoundError,
    );
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found.');
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to change password.', e);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to change password.', e);
    }
  }
}
