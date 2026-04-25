import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/profile_model.dart';

/// Handles profile Firestore reads/writes.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(
    this._firestore,
    this._firebaseAuth,
    this._firebaseStorage,
  );

  // Storage objects may be briefly unavailable for read-after-write; this
  // allows up to ~8.4s total backoff (0.4 + 0.8 + ... + 2.0) before failing.
  static const int _downloadUrlRetryAttempts = 6;
  static const int _downloadUrlRetryBaseDelayMs = 400;
  static const String _objectNotFoundCode = 'object-not-found';
  static final RegExp _objectNotFoundTokenPattern = RegExp(
    r'(^|[^a-z0-9-])object-not-found([^a-z0-9-]|$)',
  );
  static final RegExp _firebaseStorageNotFoundMessagePattern = RegExp(
    r'object does not exist at location',
    caseSensitive: false,
  );
  static final RegExp _firebaseStorageNotFoundDetailsPattern = RegExp(
    r'("code"\s*:\s*404|httpresult:\s*404)',
    caseSensitive: false,
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
      final normalizedExtension = extension.toLowerCase();
      const possibleExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      for (final ext in possibleExtensions) {
        if (ext == normalizedExtension) continue;
        await _deleteAvatarIfExists(uid, ext);
      }

      final ref = _firebaseStorage.ref().child('avatars/$uid.$normalizedExtension');
      final data = Uint8List.fromList(bytes);
      final metadata = SettableMetadata(contentType: contentType);
      try {
        await ref.putData(data, metadata);
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          const objectNotFoundRetryDelayMillis = 500;
          await Future<void>.delayed(
            const Duration(milliseconds: objectNotFoundRetryDelayMillis),
          );
          await ref.putData(data, metadata);
        } else {
          rethrow;
        }
      }
      final photoUrl = await _getDownloadUrlWithRetry(ref);
      final userDoc = _firestore.collection('users').doc(uid);
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

  Future<void> _deleteAvatarIfExists(String uid, String extension) async {
    final normalizedUid = uid.trim();
    final normalizedExtension = extension.trim().toLowerCase();
    if (normalizedUid.isEmpty || normalizedExtension.isEmpty) {
      debugPrint(
        'Skipping old avatar deletion due to invalid storage path segments.',
      );
      return;
    }

    final objectPath = 'avatars/$normalizedUid.$normalizedExtension';
    try {
      await _firebaseStorage.ref(objectPath).delete();
    } on FirebaseException catch (e) {
      if (_isObjectNotFoundError(code: e.code, message: e.message)) {
        debugPrint('No old PFP found at $objectPath');
        return;
      }
      rethrow;
    } on PlatformException catch (e) {
      if (_isObjectNotFoundError(
        code: e.code,
        message: e.message,
        details: e.details?.toString(),
      )) {
        debugPrint('No old PFP found at $objectPath');
        return;
      }
      rethrow;
    }
  }

  bool _isObjectNotFoundError({
    required String code,
    String? message,
    String? details,
  }) {
    const objectNotFoundCodes = {
      _objectNotFoundCode,
      'storage/$_objectNotFoundCode',
      'firebase_storage/$_objectNotFoundCode',
    };
    const objectNotFoundNumericCodes = {
      // Native Firebase Storage not-found code observed on some platforms.
      '-13010',
      // HTTP not-found status surfaced through Storage exception wrappers.
      '404',
    };
    final normalizedCode = code.trim();
    if (objectNotFoundCodes.contains(normalizedCode.toLowerCase()) ||
        objectNotFoundNumericCodes.contains(normalizedCode)) {
      return true;
    }

    final normalizedMessage = (message ?? '').toLowerCase();
    final normalizedDetails = (details ?? '').toLowerCase();
    if (_firebaseStorageNotFoundMessagePattern.hasMatch(normalizedMessage) ||
        _firebaseStorageNotFoundMessagePattern.hasMatch(normalizedDetails) ||
        _firebaseStorageNotFoundDetailsPattern.hasMatch(normalizedDetails)) {
      return true;
    }

    return _containsObjectNotFoundToken(normalizedMessage) ||
        _containsObjectNotFoundToken(normalizedDetails);
  }

  bool _containsObjectNotFoundToken(String value) {
    return _objectNotFoundTokenPattern.hasMatch(value);
  }

  Future<String> _getDownloadUrlWithRetry(
    Reference ref, {
    int maxAttempts = _downloadUrlRetryAttempts,
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
          await Future<void>.delayed(
            Duration(milliseconds: _downloadUrlRetryBaseDelayMs * attempt),
          );
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
