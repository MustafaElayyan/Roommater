import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

// --- Dependency graph ---

final _taskDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(ref.watch(apiClientProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(_taskDataSourceProvider));
});

final _getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final _createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final _updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final _deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

// --- State ---

/// Fetches all tasks for the current household.
final tasksProvider = FutureProvider<List<TaskEntity>>((ref) {
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return [];
  return ref.watch(_getTasksUseCaseProvider)(household.id);
});

// --- Controller ---

/// Manages task interactions from the UI.
class TaskController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedToUserId,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_createTaskUseCaseProvider)(
        household.id,
        title: title,
        description: description,
        dueDate: dueDate,
        assignedToUserId: assignedToUserId,
      );
      ref.invalidate(tasksProvider);
    });
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    String? assignedToUserId,
  }) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_updateTaskUseCaseProvider)(
        household.id,
        taskId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        dueDate: dueDate,
        assignedToUserId: assignedToUserId,
      );
      ref.invalidate(tasksProvider);
    });
  }

  Future<void> deleteTask(String taskId) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_deleteTaskUseCaseProvider)(household.id, taskId);
      ref.invalidate(tasksProvider);
    });
  }

  Future<void> toggleComplete(TaskEntity task) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_updateTaskUseCaseProvider)(
        household.id,
        task.id,
        title: task.title,
        description: task.description,
        isCompleted: !task.isCompleted,
        dueDate: task.dueDate,
        assignedToUserId: task.assignedToUserId,
      );
      ref.invalidate(tasksProvider);
    });
  }
}

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, void>(
  TaskController.new,
);
