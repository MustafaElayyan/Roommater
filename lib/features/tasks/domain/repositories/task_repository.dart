import '../entities/task_entity.dart';

/// Contract for task operations.
abstract interface class TaskRepository {
  /// Returns tasks for the household with [householdId].
  Stream<List<TaskEntity>> watchTasks(
    String householdId, {
    bool myTasks = false,
    int? pageSize,
  });

  /// Creates a new task in the household with [householdId].
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
  });

  /// Updates the task with [taskId] in the household with [householdId].
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
  });

  /// Deletes the task with [taskId] from the household with [householdId].
  Future<void> deleteTask(String householdId, String taskId);
}
