import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case: update an existing task in a household.
class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity> call(
    String householdId,
    String taskId, {
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    String? assignedToUserId,
    String? assignedToName,
    String? completionNote,
  }) =>
      _repository.updateTask(
        householdId,
        taskId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        dueDate: dueDate,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
        completionNote: completionNote,
      );
}
