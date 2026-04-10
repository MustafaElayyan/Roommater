import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/settle_expense_usecase.dart';

final _expenseDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(_expenseDataSourceProvider));
});

final _getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final _createExpenseUseCaseProvider = Provider<CreateExpenseUseCase>((ref) {
  return CreateExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final _settleExpenseUseCaseProvider = Provider<SettleExpenseUseCase>((ref) {
  return SettleExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final expensesProvider = FutureProvider<List<ExpenseEntity>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return [];
  return ref.watch(_getExpensesUseCaseProvider)(household.id);
});

class ExpenseController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createExpense({
    required String title,
    required double amount,
    String? category,
    required String payerId,
    required List<ExpenseSplitEntity> splits,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_createExpenseUseCaseProvider)(
            household.id,
            title: title,
            amount: amount,
            category: category,
            payerId: payerId,
            splits: splits,
          );
      ref.invalidate(expensesProvider);
    });
  }

  Future<void> settleExpense({
    required String expenseId,
    required String userId,
    required bool isSettled,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_settleExpenseUseCaseProvider)(
            household.id,
            expenseId,
            userId: userId,
            isSettled: isSettled,
          );
      ref.invalidate(expensesProvider);
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(expenseRepositoryProvider).deleteExpense(household.id, expenseId);
      ref.invalidate(expensesProvider);
    });
  }
}

final expenseControllerProvider = AsyncNotifierProvider<ExpenseController, void>(
  ExpenseController.new,
);
