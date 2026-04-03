import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

/// Use case: join an existing household via invite code.
class JoinHouseholdUseCase {
  const JoinHouseholdUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<HouseholdEntity> call(String inviteCode) =>
      _repository.joinHousehold(inviteCode);
}
