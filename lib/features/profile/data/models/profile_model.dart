import '../../domain/entities/profile_entity.dart';

/// Data-layer model for a Firestore user profile document.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.bio,
    super.photoUrl,
    super.age,
    super.occupation,
    super.location,
  });

  factory ProfileModel.fromFirestore(String uid, Map<String, dynamic> data) {
    return ProfileModel(
      uid: uid,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      bio: data['bio'] as String?,
      photoUrl: data['photoUrl'] as String?,
      age: data['age'] as int?,
      occupation: data['occupation'] as String?,
      location: data['location'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      if (bio != null) 'bio': bio,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (age != null) 'age': age,
      if (occupation != null) 'occupation': occupation,
      if (location != null) 'location': location,
    };
  }
}
