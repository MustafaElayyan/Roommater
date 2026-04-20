import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _myTasks = true;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final authState = ref.watch(authStateProvider);
    final currentUid = authState.valueOrNull?.uid;

    final household = ref.watch(currentHouseholdProvider);
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
              ? tasks
                  .where((t) => t.assignedToUserId == currentUid)
                  .toList()
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
                  final assigneeName = task.assignedToName ?? _resolveAssignee(task, members);
                  final creatorName = task.createdByName ?? _resolveCreator(task, members);
                  final dueText = _formatDueDate(task.dueDate);
                  final userCanCompleteTask = task.assignedToUserId == currentUid;
                  final userCanEditDueDate = task.createdByUserId == currentUid;
                  final userCanDeleteTask = task.createdByUserId == currentUid;
                  return Card(
                    child: ListTile(
                      leading: userCanCompleteTask
                          ? Checkbox(
                              value: done,
                              onChanged: (_) => _toggleTask(context, ref, task),
                            )
                          : null,
                      trailing: (userCanEditDueDate || userCanDeleteTask)
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (userCanEditDueDate)
                                  IconButton(
                                    icon: const Icon(Icons.edit_calendar_outlined),
                                    onPressed: () => _editDueDate(context, ref, task),
                                  ),
                                if (userCanDeleteTask)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _confirmDeleteTask(context, ref, task),
                                  ),
                              ],
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
                          _buildMemberProfileLink(
                            context,
                            members: members,
                            uid: task.createdByUserId,
                            label: 'Created by',
                            fallbackName: creatorName ?? task.createdByUserId,
                          ),
                          _buildMemberProfileLink(
                            context,
                            members: members,
                            uid: task.assignedToUserId,
                            label: 'Assigned to',
                            fallbackName: assigneeName ?? 'Unassigned',
                          ),
                          if (dueText != null) Text('Due: $dueText'),
                          if (task.completionNote != null &&
                              task.completionNote!.trim().isNotEmpty)
                            Text('Completion note: ${task.completionNote}'),
                        ],
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

  String? _resolveAssignee(TaskEntity task, List<MemberEntity> members) {
    if (task.assignedToUserId == null) return null;
    final match = members
        .where((m) => m.uid == task.assignedToUserId)
        .toList();
    return match.isNotEmpty ? match.first.displayName : task.assignedToUserId;
  }

  String? _resolveCreator(TaskEntity task, List<MemberEntity> members) {
    final match = members.where((m) => m.uid == task.createdByUserId).toList();
    return match.isNotEmpty ? match.first.displayName : null;
  }

  Widget _buildMemberProfileLink(
    BuildContext context, {
    required List<MemberEntity> members,
    required String? uid,
    required String label,
    required String fallbackName,
  }) {
    if (uid == null || uid.trim().isEmpty) {
      return Text('$label: $fallbackName');
    }
    MemberEntity? member;
    for (final candidate in members) {
      if (candidate.uid == uid) {
        member = candidate;
        break;
      }
    }
    final displayName = (member?.displayName.trim().isNotEmpty ?? false)
        ? member!.displayName
        : fallbackName;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: () => context.push(AppRoutes.profileDetailsFor(uid)),
        borderRadius: BorderRadius.circular(20),
        child: Text(
          '$label: $displayName',
          overflow: TextOverflow.ellipsis,
        ),
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

  Future<void> _editDueDate(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) async {
    final current = task.dueDate ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: current,
    );
    if (date == null || !context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (!context.mounted) return;
    final time = pickedTime ?? TimeOfDay(hour: current.hour, minute: current.minute);
    final dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await ref.read(taskControllerProvider.notifier).updateTask(
          taskId: task.id,
          title: task.title,
          description: task.description,
          isCompleted: task.isCompleted,
          dueDate: dueDate,
          assignedToUserId: task.assignedToUserId,
          assignedToName: task.assignedToName,
          completionNote: task.completionNote,
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
}
