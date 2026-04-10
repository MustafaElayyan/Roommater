import '../entities/task_entity.dart';

/// Contract for task operations.
abstract interface class TaskRepository {
  /// Returns tasks for the household with [householdId].
  Future<List<TaskEntity>> getTasks(
    String householdId, {
    bool? myTasks,
    int? page,
    int? pageSize,
  });

  /// Creates a new task in the household with [householdId].
  Future<TaskEntity> createTask(
    String householdId, {
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedToUserId,
    String? assignedToName,
  });

  /// Updates the task with [taskId] in the household with [householdId].
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
  });

  /// Deletes the task with [taskId] from the household with [householdId].
  Future<void> deleteTask(String householdId, String taskId);
}
