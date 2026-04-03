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
                  final assigneeName = _resolveAssignee(task, members);
                  final dueText = _formatDueDate(task.dueDate);
                  return Card(
                    child: CheckboxListTile(
                      value: done,
                      onChanged: (_) {
                        ref
                            .read(taskControllerProvider.notifier)
                            .toggleComplete(task);
                      },
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (assigneeName != null)
                            Chip(label: Text(assigneeName)),
                          if (dueText != null) Text('Due: $dueText'),
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
        onPressed: () => context.go(AppRoutes.createTask),
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
