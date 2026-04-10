import 'package:flutter/foundation.dart';

/// Represents a signed-in Roommater user in the domain layer.
///
/// This entity is independent of any backend-specific model so that the
/// domain layer has no external dependencies.
@immutable
class UserEntity {
  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.householdId,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? householdId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
