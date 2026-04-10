import '../entities/grocery_item_entity.dart';

abstract interface class GroceryRepository {
  Stream<List<GroceryItemEntity>> watchItems(
    String householdId, {
    required bool isPurchased,
  });

  Future<void> addItem(
    String householdId, {
    required String name,
    required int quantity,
  });

  Future<void> togglePurchased(
    String householdId,
    String itemId, {
    required bool isPurchased,
  });

  Future<void> deleteItem(String householdId, String itemId);
}
