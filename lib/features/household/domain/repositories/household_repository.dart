import '../entities/household_entity.dart';
import '../entities/member_entity.dart';

/// Contract for household operations.
abstract interface class HouseholdRepository {
  /// Creates a new household with the given [name].
  Future<HouseholdEntity> createHousehold(String name);

  /// Joins an existing household using an [inviteCode].
  Future<HouseholdEntity> joinHousehold(String inviteCode);

  /// Returns the household for [id].
  Future<HouseholdEntity> getHousehold(String id);

  /// Returns all members of the household with [householdId].
  Future<List<MemberEntity>> getMembers(String householdId);

  /// Removes the member with [userId] from the household with [householdId].
  Future<void> removeMember(String householdId, String userId);

  /// Removes the current signed-in user from [householdId].
  Future<void> leaveHousehold(String householdId);

  /// Updates the household display name.
  Future<HouseholdEntity> updateHouseholdName({
    required String householdId,
    required String name,
  });

  /// Deletes the household with [id].
  Future<void> deleteHousehold(String id);
}
