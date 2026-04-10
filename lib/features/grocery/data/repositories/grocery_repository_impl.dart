import '../../domain/entities/grocery_item_entity.dart';
import '../../domain/repositories/grocery_repository.dart';
import '../datasources/grocery_remote_datasource.dart';

class GroceryRepositoryImpl implements GroceryRepository {
  const GroceryRepositoryImpl(this._dataSource);

  final GroceryRemoteDataSource _dataSource;

  @override
  Stream<List<GroceryItemEntity>> watchItems(
    String householdId, {
    required bool isPurchased,
  }) {
    return _dataSource.watchItems(householdId, isPurchased: isPurchased);
  }

  @override
  Future<void> addItem(
    String householdId, {
    required String name,
    required int quantity,
  }) {
    return _dataSource.addItem(householdId, name: name, quantity: quantity);
  }

  @override
  Future<void> togglePurchased(
    String householdId,
    String itemId, {
    required bool isPurchased,
  }) {
    return _dataSource.togglePurchased(householdId, itemId, isPurchased: isPurchased);
  }

  @override
  Future<void> deleteItem(String householdId, String itemId) {
    return _dataSource.deleteItem(householdId, itemId);
  }
}
