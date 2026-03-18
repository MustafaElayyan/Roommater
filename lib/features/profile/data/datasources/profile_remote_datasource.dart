import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/profile_model.dart';

/// Handles Firestore reads/writes for user profiles.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.usersCollection);

  Future<ProfileModel> getProfile(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) throw const FirestoreException('Profile not found.');
      return ProfileModel.fromFirestore(uid, doc.data()!);
    } catch (e) {
      throw FirestoreException('Failed to load profile.', e);
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      await _col.doc(profile.uid).set(
            profile.toFirestore(),
            SetOptions(merge: true),
          );
      return profile;
    } catch (e) {
      throw FirestoreException('Failed to update profile.', e);
    }
  }
}
