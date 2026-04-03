import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/task_model.dart';

/// Handles task API reads/writes.
class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TaskModel>> getTasks(
    String householdId, {
    bool? myTasks,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (myTasks != null) 'myTasks': myTasks,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
      };
      final response = await _apiClient.getJsonList(
        'households/$householdId/tasks',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return response
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException catch (e) {
      throw ApiException('Failed to load tasks.', e);
    }
  }

  Future<TaskModel> createTask(
    String householdId, {
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedToUserId,
  }) async {
    try {
      final response = await _apiClient.postJson(
        'households/$householdId/tasks',
        body: {
          'title': title,
          if (description != null) 'description': description,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
          if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
        },
      );
      return TaskModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to create task.', e);
    }
  }

  Future<TaskModel> updateTask(
    String householdId,
    String taskId, {
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    String? assignedToUserId,
  }) async {
    try {
      final response = await _apiClient.putJson(
        'households/$householdId/tasks/$taskId',
        body: {
          'title': title,
          if (description != null) 'description': description,
          'isCompleted': isCompleted,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
          if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
        },
      );
      return TaskModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to update task.', e);
    }
  }

  Future<void> deleteTask(String householdId, String taskId) async {
    try {
      await _apiClient.delete('households/$householdId/tasks/$taskId');
    } on AppException catch (e) {
      throw ApiException('Failed to delete task.', e);
    }
  }
}
