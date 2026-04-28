import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
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
  return TaskRemoteDataSource(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
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

final myTasksFilterProvider = StateProvider<bool>((ref) => true);

/// Watches all tasks for the current household.
final tasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final household = ref.watch(currentHouseholdProvider);
  if (household == null) return const Stream.empty();
  final myTasks = ref.watch(myTasksFilterProvider);
  return ref.watch(_getTasksUseCaseProvider)(
    household.id,
    myTasks: myTasks,
  );
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
    List<String> assignedToUserIds = const [],
    List<String> assignedToNames = const [],
    String? assignedToUserId,
    String? assignedToName,
    List<int> repeatDays = const [],
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
        assignedToUserIds: assignedToUserIds,
        assignedToNames: assignedToNames,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
        repeatDays: repeatDays,
      );
    });
  }

  Future<void> updateTask({
    required String taskId,
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
        assignedToUserIds: assignedToUserIds,
        assignedToNames: assignedToNames,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
        completionNote: completionNote,
        repeatDays: repeatDays,
        approvalStatus: approvalStatus,
      );
    });
  }

  Future<void> deleteTask(String taskId) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_deleteTaskUseCaseProvider)(household.id, taskId);
    });
  }

  Future<void> toggleComplete(TaskEntity task, {String? completionNote}) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;
    final currentUid = ref.read(firebaseAuthProvider).currentUser?.uid;
    final isAssigned = task.assignedToUserIds.contains(currentUid) ||
        task.assignedToUserId == currentUid;
    if (!isAssigned || task.approvalStatus != TaskEntity.statusActive) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_updateTaskUseCaseProvider)(
        household.id,
        task.id,
        title: task.title,
        description: task.description,
        isCompleted: !task.isCompleted,
        dueDate: task.dueDate,
        assignedToUserIds: task.assignedToUserIds,
        assignedToNames: task.assignedToNames,
        assignedToUserId: task.assignedToUserId,
        assignedToName: task.assignedToName,
        completionNote: !task.isCompleted ? completionNote : null,
        repeatDays: task.repeatDays,
        approvalStatus: task.approvalStatus,
      );
    });
  }

  Future<void> approveTask(TaskEntity task) async {
    final household = ref.read(currentHouseholdProvider);
    if (household == null) return;
    final currentUid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (currentUid == null || currentUid != household.createdByUserId) return;
    if (task.approvalStatus == TaskEntity.statusActive) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_updateTaskUseCaseProvider)(
        household.id,
        task.id,
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
        dueDate: task.dueDate,
        assignedToUserIds: task.assignedToUserIds,
        assignedToNames: task.assignedToNames,
        assignedToUserId: task.assignedToUserId,
        assignedToName: task.assignedToName,
        completionNote: task.completionNote,
        repeatDays: task.repeatDays,
        approvalStatus: TaskEntity.statusActive,
      );
    });
  }
}

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, void>(
  TaskController.new,
);
