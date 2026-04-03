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
}
