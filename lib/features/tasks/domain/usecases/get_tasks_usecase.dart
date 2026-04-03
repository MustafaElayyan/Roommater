import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case: fetch tasks for a household.
class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<TaskEntity>> call(
    String householdId, {
    bool? myTasks,
    int? page,
    int? pageSize,
  }) =>
      _repository.getTasks(
        householdId,
        myTasks: myTasks,
        page: page,
        pageSize: pageSize,
      );
}
