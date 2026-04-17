import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Use case: fetch tasks for a household.
class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<TaskEntity>> call(
    String householdId, {
    bool? myTasks,
    int? page,
    int? pageSize,
  }) =>
      _repository.watchTasks(
        householdId,
        myTasks: myTasks,
        page: page,
        pageSize: pageSize,
      );
}
