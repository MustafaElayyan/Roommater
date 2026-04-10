import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';
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
    final taskChecks = ref.watch(homeTaskChecksProvider);

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
              if (tasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tasks yet'),
                );
              }
              return Column(
                children: tasks
                    .map(
                      (task) => CheckboxListTile(
                        value: taskChecks[task.id] ?? task.isCompleted,
                        onChanged: (_) => _toggleTask(ref, task),
                        title: Text(task.title),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('Upcoming Events', style: Theme.of(context).textTheme.titleMedium),
        const Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No upcoming events yet'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No notifications yet'),
          ),
        ),
      ],
    );
  }

  void _toggleTask(WidgetRef ref, TaskEntity task) {
    ref.read(taskControllerProvider.notifier).toggleComplete(task);
  }
}
