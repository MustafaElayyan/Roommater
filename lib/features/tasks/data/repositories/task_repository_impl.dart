import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

/// API-backed implementation of [TaskRepository].
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._dataSource);

  final TaskRemoteDataSource _dataSource;

  @override
  Future<List<TaskEntity>> getTasks(
    String householdId, {
    bool? myTasks,
    int? page,
    int? pageSize,
  }) {
    return _dataSource.getTasks(
      householdId,
      myTasks: myTasks,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<TaskEntity> createTask(
    String householdId, {
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedToUserId,
  }) {
    return _dataSource.createTask(
      householdId,
      title: title,
      description: description,
      dueDate: dueDate,
      assignedToUserId: assignedToUserId,
    );
  }

  @override
  Future<TaskEntity> updateTask(
    String householdId,
    String taskId, {
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    String? assignedToUserId,
  }) {
    return _dataSource.updateTask(
      householdId,
      taskId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      dueDate: dueDate,
      assignedToUserId: assignedToUserId,
    );
  }

  @override
  Future<void> deleteTask(String householdId, String taskId) {
    return _dataSource.deleteTask(householdId, taskId);
  }
}
