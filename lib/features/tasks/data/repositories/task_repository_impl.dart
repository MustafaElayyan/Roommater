import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

/// API-backed implementation of [TaskRepository].
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._dataSource);

  final TaskRemoteDataSource _dataSource;

  @override
  Stream<List<TaskEntity>> watchTasks(
    String householdId, {
    bool? myTasks,
    int? pageSize,
  }) {
    return _dataSource.watchTasks(
      householdId,
      myTasks: myTasks,
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
    String? assignedToName,
  }) {
    return _dataSource.createTask(
      householdId,
      title: title,
      description: description,
      dueDate: dueDate,
      assignedToUserId: assignedToUserId,
      assignedToName: assignedToName,
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
    String? assignedToName,
    String? completionNote,
  }) {
    return _dataSource.updateTask(
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

  @override
  Future<void> deleteTask(String householdId, String taskId) {
    return _dataSource.deleteTask(householdId, taskId);
  }
}
