import '../repositories/grocery_repository.dart';

class ToggleGroceryItemUseCase {
  const ToggleGroceryItemUseCase(this._repository);

  final GroceryRepository _repository;

  Future<void> call(
    String householdId,
    String itemId, {
    required bool isPurchased,
  }) {
    return _repository.togglePurchased(
      householdId,
      itemId,
      isPurchased: isPurchased,
    );
  }
}
