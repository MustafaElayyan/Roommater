import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case: create a new task in a household.
class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity> call(
    String householdId, {
    required String title,
    String? description,
    DateTime? dueDate,
    List<String> assignedToUserIds = const [],
    List<String> assignedToNames = const [],
    String? assignedToUserId,
    String? assignedToName,
    List<int> repeatDays = const [],
  }) =>
      _repository.createTask(
        householdId,
        title: title,
        description: description,
        dueDate: dueDate,
        assignedToUserIds: assignedToUserIds,
        assignedToNames: assignedToNames,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
        repeatDays: repeatDays,
      );
}
