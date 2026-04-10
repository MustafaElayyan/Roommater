import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class SettleExpenseUseCase {
  const SettleExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseEntity> call(
    String householdId,
    String expenseId, {
    required String userId,
    required bool isSettled,
  }) {
    return _repository.settleExpenseSplit(
      householdId,
      expenseId,
      userId: userId,
      isSettled: isSettled,
    );
  }
}
