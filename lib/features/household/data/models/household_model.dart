import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/household_entity.dart';
import 'member_model.dart';

/// Data-layer model for a household payload.
class HouseholdModel extends HouseholdEntity {
  const HouseholdModel({
    required super.id,
    required super.name,
    required super.inviteCode,
    required super.createdByUserId,
    required super.createdAt,
    super.members,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> data) {
    final membersJson = data['members'] as List<dynamic>? ?? [];
    return HouseholdModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      createdByUserId: data['createdByUserId'] as String? ?? '',
      createdAt: DateTime.parse(
        data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      members: membersJson
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory HouseholdModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final membersRaw = data['members'] as List<dynamic>? ?? const [];
    final createdAtRaw = data['createdAt'];
    return HouseholdModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      createdByUserId: data['createdByUserId'] as String? ?? '',
      createdAt: switch (createdAtRaw) {
        Timestamp() => createdAtRaw.toDate(),
        String() => DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
      members: membersRaw
          .whereType<Map<String, dynamic>>()
          .map(MemberModel.fromFirestore)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
      'members': members
          .map((e) => MemberModel(
                uid: e.uid,
                displayName: e.displayName,
                email: e.email,
                photoUrl: e.photoUrl,
              ).toJson())
          .toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'createdByUserId': createdByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members
          .map((e) => MemberModel(
                uid: e.uid,
                displayName: e.displayName,
                email: e.email,
                photoUrl: e.photoUrl,
              ).toFirestore())
          .toList(),
    };
  }
}
