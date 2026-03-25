import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  'Sunrise Apartment 4B',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    CircleAvatar(child: Text('A')),
                    SizedBox(width: 8),
                    CircleAvatar(child: Text('L')),
                    SizedBox(width: 8),
                    CircleAvatar(child: Text('M')),
                    SizedBox(width: 8),
                    CircleAvatar(child: Text('S')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("Today's Tasks", style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: Column(
            children: [
              CheckboxListTile(
                value: taskChecks[0],
                onChanged: (v) => _toggleTask(ref, 0, v),
                title: const Text('Wash dishes'),
              ),
              CheckboxListTile(
                value: taskChecks[1],
                onChanged: (v) => _toggleTask(ref, 1, v),
                title: const Text('Take out trash'),
              ),
              CheckboxListTile(
                value: taskChecks[2],
                onChanged: (v) => _toggleTask(ref, 2, v),
                title: const Text('Clean living room'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Upcoming Events', style: Theme.of(context).textTheme.titleMedium),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.event),
                title: Text('House Meeting'),
                subtitle: Text('Tomorrow • 7:00 PM'),
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Movie Night'),
                subtitle: Text('Friday • 9:00 PM'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('Ahmad completed Kitchen cleaning task'),
              ),
              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('New expense added: Grocery run'),
              ),
              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('Lana joined the house meeting event'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleTask(WidgetRef ref, int index, bool? value) {
    final next = [...ref.read(homeTaskChecksProvider)];
    next[index] = value ?? false;
    ref.read(homeTaskChecksProvider.notifier).state = next;
  }
}
