import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/presentation/controllers/event_controller.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _DashboardTab();
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(currentHouseholdProvider);
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);
    final tasksAsync = ref.watch(tasksProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final taskChecks = ref.watch(homeTaskChecksProvider);
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  household?.name ?? 'No household selected',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                membersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => const Text('Failed to load members'),
                  data: (members) {
                    if (members.isEmpty) {
                      return const Text('No household members yet');
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: members
                          .map(
                            (member) {
                              final hasPhoto = member.photoUrl?.isNotEmpty ?? false;
                              return CircleAvatar(
                                backgroundImage:
                                    hasPhoto ? NetworkImage(member.photoUrl!) : null,
                                child: hasPhoto
                                    ? null
                                    : Text(
                                        member.displayName.isNotEmpty
                                            ? member.displayName[0].toUpperCase()
                                            : '?',
                                      ),
                              );
                            },
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("Today's Tasks", style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: tasksAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load tasks: $error'),
            ),
            data: (tasks) {
              final todaysTasks = _todayTasks(tasks);
              if (todaysTasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tasks due today'),
                );
              }
              return Column(
                children: todaysTasks
                    .map(
                      (task) => CheckboxListTile(
                        value: taskChecks[task.id] ?? task.isCompleted,
                        onChanged: task.assignedToUserId == currentUid
                            ? (_) => _toggleTask(context, ref, task)
                            : null,
                        title: Text(task.title),
                        subtitle: membersAsync.maybeWhen(
                          data: (members) {
                            final creator = task.createdByName ??
                                _findMemberName(members, task.createdByUserId) ??
                                task.createdByUserId;
                            final assignee = task.assignedToName ??
                                _findMemberName(members, task.assignedToUserId) ??
                                task.assignedToUserId ??
                                'Unassigned';
                            return Text('Created by: $creator\nAssigned to: $assignee');
                          },
                          orElse: () => null,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('Upcoming Events', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: eventsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load events: $error'),
            ),
            data: (events) {
              final upcomingEvents = _upcomingEvents(events);
              if (upcomingEvents.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No upcoming events yet'),
                );
              }
              return Column(
                children: upcomingEvents
                    .map(
                      (event) => ListTile(
                        onTap: () => context.go('/events/${event.id}'),
                        title: Text(event.title),
                        subtitle: Text(_eventSubtitle(event)),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Card(
          child: notificationsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load notifications: $error'),
            ),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No notifications yet'),
                );
              }
              final recentNotifications = notifications.take(3).toList();
              return Column(
                children: recentNotifications
                    .map((notification) => _buildNotificationTile(ref, notification))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(WidgetRef ref, NotificationEntity notification) {
    return ListTile(
      tileColor: notification.isRead ? null : Colors.blue.withValues(alpha: 0.08),
      title: Text(notification.title),
      subtitle: notification.body == null ? null : Text(notification.body!),
      trailing: notification.isRead
          ? const Icon(Icons.done_all, size: 18)
          : const Icon(Icons.mark_email_unread_outlined, size: 18),
      onTap: notification.isRead
          ? null
          : () {
              ref
                  .read(notificationControllerProvider.notifier)
                  .markAsRead(notification.id);
            },
    );
  }

  Future<void> _toggleTask(BuildContext context, WidgetRef ref, TaskEntity task) async {
    String? note;
    if (!task.isCompleted) {
      final controller = TextEditingController();
      try {
        note = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Complete Task'),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add completion note (optional)',
              ),
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
      } finally {
        controller.dispose();
      }
      if (note == null) return;
    }
    ref.read(taskControllerProvider.notifier).toggleComplete(
          task,
          completionNote: note,
        );
  }

  String? _findMemberName(List<MemberEntity> members, String? uid) {
    if (uid == null) return null;
    for (final member in members) {
      if (member.uid == uid) return member.displayName;
    }
    return null;
  }

  List<EventEntity> _upcomingEvents(List<EventEntity> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = events
        .where((event) => !event.eventDate.isBefore(today))
        .toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return upcoming.take(3).toList();
  }

  List<TaskEntity> _todayTasks(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((task) {
      final dueDate = task.dueDate;
      if (dueDate == null) return false;
      final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
      return dueDay == today;
    }).toList();
  }

  String _eventSubtitle(EventEntity event) {
    final date =
        '${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}';
    final time = event.eventTime == null ? '' : ' • ${event.eventTime}';
    return '$date$time • ${event.eventType}';
  }
}
