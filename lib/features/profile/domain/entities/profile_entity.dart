import 'package:flutter/foundation.dart';

/// Domain entity for a user's Roommater profile.
@immutable
class ProfileEntity {
  const ProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.bio,
    this.phone,
    this.photoUrl,
    this.age,
    this.occupation,
    this.location,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? bio;
  final String? phone;
  final String? photoUrl;
  final int? age;
  final String? occupation;
  final String? location;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
