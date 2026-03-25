import '../../domain/entities/profile_entity.dart';

/// Data-layer model for a user profile payload.
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

  factory ProfileModel.fromJson(Map<String, dynamic> data) {
    return ProfileModel(
      uid: data['uid'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      bio: data['bio'] as String?,
      photoUrl: data['photoUrl'] as String?,
      age: data['age'] as int?,
      occupation: data['occupation'] as String?,
      location: data['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
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
