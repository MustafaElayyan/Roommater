import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/profile_entity.dart';

/// Data-layer model for a user profile payload.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.bio,
    super.phone,
    super.photoUrl,
    super.age,
    super.occupation,
    super.location,
  });

  factory ProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ProfileModel(
      uid: data['uid'] as String? ?? doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      bio: data['bio'] as String?,
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      age: data['age'] as int?,
      occupation: data['occupation'] as String?,
      location: data['location'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'phone': phone,
      'photoUrl': photoUrl,
      'age': age,
      'occupation': occupation,
      'location': location,
    };
  }
}
