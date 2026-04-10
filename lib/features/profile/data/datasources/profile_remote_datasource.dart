import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/profile_model.dart';

/// Handles profile Firestore reads/writes.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

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
}
