import '../../../../core/errors/app_exception.dart';
import '../repositories/grocery_repository.dart';

class AddGroceryItemUseCase {
  const AddGroceryItemUseCase(this._repository);

  final GroceryRepository _repository;

  Future<void> call(
    String householdId, {
    required String name,
    required int quantity,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const AppException('Item name is required.');
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(trimmedName)) {
      throw const AppException('Item name must contain at least one letter.');
    }
    return _repository.addItem(
      householdId,
      name: trimmedName,
      quantity: quantity,
    );
  }
}
