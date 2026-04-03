import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

/// Use case: fetch a household by ID.
class GetHouseholdUseCase {
  const GetHouseholdUseCase(this._repository);

  final HouseholdRepository _repository;

  Future<HouseholdEntity> call(String id) => _repository.getHousehold(id);
}
