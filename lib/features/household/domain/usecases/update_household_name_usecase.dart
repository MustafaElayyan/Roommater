import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

/// Use case: update a household's name.
class UpdateHouseholdNameUseCase {
  const UpdateHouseholdNameUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<HouseholdEntity> call({
    required String householdId,
    required String name,
  }) {
    return _repository.updateHouseholdName(
      householdId: householdId,
      name: name,
    );
  }
}
