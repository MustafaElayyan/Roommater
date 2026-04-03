import '../entities/member_entity.dart';
import '../repositories/household_repository.dart';

/// Use case: fetch all members of a household.
class GetMembersUseCase {
  const GetMembersUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<List<MemberEntity>> call(String householdId) =>
      _repository.getMembers(householdId);
}
