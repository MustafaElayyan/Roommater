import 'package:flutter/foundation.dart';

import 'member_entity.dart';

/// Domain entity representing a household.
@immutable
class HouseholdEntity {
  const HouseholdEntity({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdByUserId,
    required this.createdAt,
    this.members = const [],
  });

  final String id;
  final String name;
  final String inviteCode;
  final String createdByUserId;
  final DateTime createdAt;
  final List<MemberEntity> members;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseholdEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
