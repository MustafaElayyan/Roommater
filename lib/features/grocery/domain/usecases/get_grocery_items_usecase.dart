import '../entities/grocery_item_entity.dart';
import '../repositories/grocery_repository.dart';

class GetGroceryItemsUseCase {
  const GetGroceryItemsUseCase(this._repository);

  final GroceryRepository _repository;

  Stream<List<GroceryItemEntity>> call(
    String householdId, {
    required bool isPurchased,
  }) {
    return _repository.watchItems(householdId, isPurchased: isPurchased);
  }
}
