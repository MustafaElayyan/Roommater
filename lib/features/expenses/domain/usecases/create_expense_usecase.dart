import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class CreateExpenseUseCase {
  const CreateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseEntity> call(
    String householdId, {
    required String title,
    required double amount,
    String? category,
    required String payerId,
    required List<ExpenseSplitEntity> splits,
  }) {
    return _repository.createExpense(
      householdId,
      title: title,
      amount: amount,
      category: category,
      payerId: payerId,
      splits: splits,
    );
  }
}
