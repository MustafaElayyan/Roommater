import '../../domain/entities/household_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/household_repository.dart';
import '../datasources/household_remote_datasource.dart';

/// API-backed implementation of [HouseholdRepository].
class HouseholdRepositoryImpl implements HouseholdRepository {
  const HouseholdRepositoryImpl(this._dataSource);

  final HouseholdRemoteDataSource _dataSource;

  @override
  Future<HouseholdEntity> createHousehold(String name) {
    return _dataSource.createHousehold(name);
  }

  @override
  Future<HouseholdEntity> joinHousehold(String inviteCode) {
    return _dataSource.joinHousehold(inviteCode);
  }

  @override
  Future<HouseholdEntity> getHousehold(String id) {
    return _dataSource.getHousehold(id);
  }

  @override
  Future<List<MemberEntity>> getMembers(String householdId) {
    return _dataSource.getMembers(householdId);
  }

  @override
  Future<void> removeMember(String householdId, String userId) {
    return _dataSource.removeMember(householdId, userId);
  }

  @override
  Future<void> leaveHousehold(String householdId) {
    return _dataSource.leaveHousehold(householdId);
  }

  @override
  Future<HouseholdEntity> updateHouseholdName({
    required String householdId,
    required String name,
  }) {
    return _dataSource.updateHouseholdName(
      householdId: householdId,
      name: name,
    );
  }

  @override
  Future<void> deleteHousehold(String id) {
    return _dataSource.deleteHousehold(id);
  }
}
