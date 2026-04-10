import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  const GetExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<List<ExpenseEntity>> call(String householdId) {
    return _repository.getExpenses(householdId);
  }
}
