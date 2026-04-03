import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

/// Use case: create a new household.
class CreateHouseholdUseCase {
  const CreateHouseholdUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<HouseholdEntity> call(String name) =>
      _repository.createHousehold(name);
}
