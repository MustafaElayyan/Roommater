import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._dataSource);

  final ExpenseRemoteDataSource _dataSource;

  @override
  Future<List<ExpenseEntity>> getExpenses(String householdId) {
    return _dataSource.getExpenses(householdId);
  }

  @override
  Future<ExpenseEntity> createExpense(
    String householdId, {
    required String title,
    required double amount,
    String? category,
    required String payerId,
    required List<ExpenseSplitEntity> splits,
  }) {
    return _dataSource.createExpense(
      householdId,
      title: title,
      amount: amount,
      category: category,
      payerId: payerId,
      splits: splits
          .map(
            (split) => ExpenseSplitModel(
              userId: split.userId,
              shareAmount: split.shareAmount,
              isSettled: split.isSettled,
              settledAt: split.settledAt,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<ExpenseEntity> settleExpenseSplit(
    String householdId,
    String expenseId, {
    required String userId,
    required bool isSettled,
  }) {
    return _dataSource.settleExpenseSplit(
      householdId,
      expenseId,
      userId: userId,
      isSettled: isSettled,
    );
  }

  @override
  Future<void> deleteExpense(String householdId, String expenseId) {
    return _dataSource.deleteExpense(householdId, expenseId);
  }
}
