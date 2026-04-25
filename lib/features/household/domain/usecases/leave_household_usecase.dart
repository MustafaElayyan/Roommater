import '../repositories/household_repository.dart';

/// Use case: remove the current user from a household.
class LeaveHouseholdUseCase {
  const LeaveHouseholdUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<void> call(String householdId) => _repository.leaveHousehold(householdId);
}
