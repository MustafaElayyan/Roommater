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
    List<String> assignedToUserIds = const [],
    List<String> assignedToNames = const [],
    String? assignedToUserId,
    String? assignedToName,
    List<int> repeatDays = const [],
  }) {
    return _dataSource.createTask(
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

  @override
  Future<TaskEntity> updateTask(
    String householdId,
    String taskId, {
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    List<String> assignedToUserIds = const [],
    List<String> assignedToNames = const [],
    String? assignedToUserId,
    String? assignedToName,
    String? completionNote,
    List<int> repeatDays = const [],
    String? approvalStatus,
  }) {
    return _dataSource.updateTask(
      householdId,
      taskId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      dueDate: dueDate,
      assignedToUserIds: assignedToUserIds,
      assignedToNames: assignedToNames,
      assignedToUserId: assignedToUserId,
      assignedToName: assignedToName,
      completionNote: completionNote,
      repeatDays: repeatDays,
      approvalStatus: approvalStatus,
    );
  }

  @override
  Future<void> deleteTask(String householdId, String taskId) {
    return _dataSource.deleteTask(householdId, taskId);
  }
}
