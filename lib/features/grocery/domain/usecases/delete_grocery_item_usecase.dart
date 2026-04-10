import '../repositories/grocery_repository.dart';

class DeleteGroceryItemUseCase {
  const DeleteGroceryItemUseCase(this._repository);

  final GroceryRepository _repository;

  Future<void> call(String householdId, String itemId) {
    return _repository.deleteItem(householdId, itemId);
  }
}
