import '../../domain/entities/member_entity.dart';

/// Data-layer model for a household member payload.
class MemberModel extends MemberEntity {
  const MemberModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.photoUrl,
    super.role,
  });

  factory MemberModel.fromJson(Map<String, dynamic> data) {
    return MemberModel(
      uid: data['uid'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'member',
    );
  }

  factory MemberModel.fromFirestore(Map<String, dynamic> data) {
    return MemberModel(
      uid: data['uid'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role,
    };
  }
}
