import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../data/datasources/grocery_remote_datasource.dart';
import '../../data/repositories/grocery_repository_impl.dart';
import '../../domain/entities/grocery_item_entity.dart';
import '../../domain/repositories/grocery_repository.dart';
import '../../domain/usecases/add_grocery_item_usecase.dart';
import '../../domain/usecases/delete_grocery_item_usecase.dart';
import '../../domain/usecases/get_grocery_items_usecase.dart';
import '../../domain/usecases/toggle_grocery_item_usecase.dart';

final _groceryDataSourceProvider = Provider<GroceryRemoteDataSource>((ref) {
  return GroceryRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final groceryRepositoryProvider = Provider<GroceryRepository>((ref) {
  return GroceryRepositoryImpl(ref.watch(_groceryDataSourceProvider));
});

final _getGroceryItemsUseCaseProvider = Provider<GetGroceryItemsUseCase>((ref) {
  return GetGroceryItemsUseCase(ref.watch(groceryRepositoryProvider));
});

final _addGroceryItemUseCaseProvider = Provider<AddGroceryItemUseCase>((ref) {
  return AddGroceryItemUseCase(ref.watch(groceryRepositoryProvider));
});

final _toggleGroceryItemUseCaseProvider = Provider<ToggleGroceryItemUseCase>((ref) {
  return ToggleGroceryItemUseCase(ref.watch(groceryRepositoryProvider));
});

final _deleteGroceryItemUseCaseProvider = Provider<DeleteGroceryItemUseCase>((ref) {
  return DeleteGroceryItemUseCase(ref.watch(groceryRepositoryProvider));
});

final toBuyGroceriesProvider = StreamProvider<List<GroceryItemEntity>>((ref) {
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return const Stream.empty();
  return ref.watch(_getGroceryItemsUseCaseProvider)(
        household.id,
        isPurchased: false,
      );
});

final purchasedGroceriesProvider = StreamProvider<List<GroceryItemEntity>>((ref) {
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return const Stream.empty();
  return ref.watch(_getGroceryItemsUseCaseProvider)(
        household.id,
        isPurchased: true,
      );
});

class GroceryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addItem({
    required String name,
    required int quantity,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(_addGroceryItemUseCaseProvider)(
            household.id,
            name: name,
            quantity: quantity,
          );
    });
  }

  Future<void> togglePurchased(
    String itemId, {
    required bool isPurchased,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(_toggleGroceryItemUseCaseProvider)(
            household.id,
            itemId,
            isPurchased: isPurchased,
          );
    });
  }

  Future<void> deleteItem(String itemId) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(_deleteGroceryItemUseCaseProvider)(household.id, itemId);
    });
  }
}

final groceryControllerProvider =
    AsyncNotifierProvider<GroceryController, void>(GroceryController.new);
