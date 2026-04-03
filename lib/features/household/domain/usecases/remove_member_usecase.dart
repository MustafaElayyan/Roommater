import '../repositories/household_repository.dart';

/// Use case: remove a member from a household.
class RemoveMemberUseCase {
  const RemoveMemberUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<void> call({
    required String householdId,
    required String userId,
  }) =>
      _repository.removeMember(householdId, userId);
}
