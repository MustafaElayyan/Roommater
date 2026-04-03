import '../repositories/task_repository.dart';

/// Use case: delete a task from a household.
class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String householdId, String taskId) =>
      _repository.deleteTask(householdId, taskId);
}
