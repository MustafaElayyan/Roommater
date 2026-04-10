import '../entities/expense_entity.dart';

abstract interface class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses(String householdId);

  Future<ExpenseEntity> createExpense(
    String householdId, {
    required String title,
    required double amount,
    String? category,
    required String payerId,
    required List<ExpenseSplitEntity> splits,
  });

  Future<ExpenseEntity> settleExpenseSplit(
    String householdId,
    String expenseId, {
    required String userId,
    required bool isSettled,
  });

  Future<void> deleteExpense(String householdId, String expenseId);
}
