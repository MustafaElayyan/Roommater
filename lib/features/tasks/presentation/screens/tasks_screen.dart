import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  static const double _trailingActionsMaxHeight = 72;
  bool _myTasks = true;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final authState = ref.watch(authStateProvider);
    final currentUid = authState.valueOrNull?.uid;
    final household = ref.watch(currentHouseholdProvider);
    final isOwner = household != null && currentUid == household.createdByUserId;
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);
    final members = membersAsync.valueOrNull ?? [];

    return Scaffold(
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (tasks) {
          final visibleTasks = _myTasks && currentUid != null
              ? tasks.where((t) => _isAssignedToUser(t, currentUid)).toList()
              : tasks;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('My Tasks')),
                  ButtonSegment<bool>(value: false, label: Text('All Tasks')),
                ],
                selected: <bool>{_myTasks},
                onSelectionChanged: (selection) {
                  setState(() => _myTasks = selection.first);
                },
              ),
              const SizedBox(height: 16),
              if (visibleTasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                ...visibleTasks.map((task) {
                  final done = task.isCompleted;
                  final overdue = !done &&
                      task.dueDate != null &&
                      DateTime.now().isAfter(task.dueDate!);
                  final assigneeNames = _resolveAssignees(task, members);
                  final creatorName = _resolveCreator(task, members);
                  final dueText = _formatDueDate(task.dueDate);
                  final userCanCompleteTask =
                      currentUid != null && _isAssignedToUser(task, currentUid);
                  final userCanEditTask =
                      currentUid != null && (task.createdByUserId == currentUid || isOwner);
                  final userCanDeleteTask =
                      currentUid != null && (task.createdByUserId == currentUid || isOwner);
                  final userCanApprove =
                      isOwner && task.approvalStatus == TaskEntity.statusPendingApproval;

                  return Card(
                    color: done
                        ? Colors.green.withValues(alpha: 0.14)
                        : overdue
                            ? Colors.red.withValues(alpha: 0.12)
                            : null,
                    child: ListTile(
                      leading: userCanCompleteTask &&
                              task.approvalStatus == TaskEntity.statusActive
                          ? Checkbox(
                              value: done,
                              onChanged: (_) => _toggleTask(context, ref, task),
                            )
                          : null,
                      trailing: (userCanEditTask || userCanDeleteTask || userCanApprove)
                          ? SizedBox(
                              height: _trailingActionsMaxHeight,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (userCanEditTask)
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints.tightFor(
                                          width: 36,
                                          height: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.edit_calendar_outlined),
                                        onPressed: () => context.push(
                                          AppRoutes.editTask,
                                          extra: task,
                                        ),
                                      ),
                                    if (userCanDeleteTask)
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints.tightFor(
                                          width: 36,
                                          height: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _confirmDeleteTask(context, ref, task),
                                      ),
                                    if (userCanApprove)
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints.tightFor(
                                          width: 36,
                                          height: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.verified_outlined),
                                        onPressed: () => ref
                                            .read(taskControllerProvider.notifier)
                                            .approveTask(task),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : null,
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Assigned by: ${creatorName ?? task.createdByUserId}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Assigned to: $assigneeNames'),
                          ),
                          if (task.approvalStatus == TaskEntity.statusPendingApproval)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Chip(
                                label: Text('Pending approval'),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          if (dueText != null) Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Due: $dueText'),
                          ),
                          if (task.repeatDays.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Repeats: ${_weekdayLabels(task.repeatDays)}',
                              ),
                            ),
                          if (task.completionNote != null &&
                              task.completionNote!.trim().isNotEmpty)
                            Text('Completion note: ${task.completionNote}'),
                        ],
                      ),
                      onTap: () => _showTaskDetails(
                        context,
                        task,
                        assignedBy: creatorName ?? task.createdByUserId,
                        assignedTo: assigneeNames,
                        dueText: dueText,
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createTask),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isAssignedToUser(TaskEntity task, String? uid) {
    if (uid == null) return false;
    if (task.assignedToUserIds.contains(uid)) return true;
    return task.assignedToUserId == uid;
  }

  String _resolveAssignees(TaskEntity task, List<MemberEntity> members) {
    final ids = task.assignedToUserIds.isNotEmpty
        ? task.assignedToUserIds
        : (task.assignedToUserId == null || task.assignedToUserId!.trim().isEmpty)
            ? const <String>[]
            : <String>[task.assignedToUserId!];
    if (ids.isEmpty) return 'Unassigned';
    final names = ids.map((id) {
      for (final member in members) {
        if (member.uid == id) return member.displayName;
      }
      return id;
    }).toList();
    return names.join(', ');
  }

  String? _resolveCreator(TaskEntity task, List<MemberEntity> members) {
    final match = members.where((m) => m.uid == task.createdByUserId).toList();
    return match.isNotEmpty ? match.first.displayName : null;
  }

  Future<void> _showTaskDetails(
    BuildContext context,
    TaskEntity task, {
    required String assignedBy,
    required String assignedTo,
    String? dueText,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned by: $assignedBy'),
            const SizedBox(height: 4),
            Text('Assigned to: $assignedTo'),
            if (task.approvalStatus == TaskEntity.statusPendingApproval) ...[
              const SizedBox(height: 4),
              const Text('Status: Pending approval'),
            ],
            if (dueText != null) ...[
              const SizedBox(height: 4),
              Text('Due: $dueText'),
            ],
            if (task.repeatDays.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Repeats: ${_weekdayLabels(task.repeatDays)}'),
            ],
            if (task.description?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(task.description!.trim()),
            ],
            if (task.completionNote?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Completion note: ${task.completionNote!.trim()}'),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTask(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    await ref.read(taskControllerProvider.notifier).deleteTask(task.id);
  }

  Future<void> _toggleTask(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) async {
    String? note;
    if (!task.isCompleted) {
      note = await _showCompletionNoteDialog(context);
      if (!context.mounted) return;
      if (note == null) return;
    }
    await ref.read(taskControllerProvider.notifier).toggleComplete(
          task,
          completionNote: note,
        );
  }

  Future<String?> _showCompletionNoteDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add completion note (optional)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  String? _formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (due == today) return 'Today';
    if (due == tomorrow) return 'Tomorrow';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dueDate.month - 1]} ${dueDate.day}';
  }

  String _weekdayLabels(List<int> days) {
    const names = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final sortedDays = [...days]..sort();
    final labels = sortedDays.map((day) => names[day] ?? day.toString()).toList();
    return labels.join(', ');
  }
}
