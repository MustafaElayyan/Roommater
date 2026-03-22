import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool myTasks = true;
  static const String _currentUser = 'Mustafa';
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Wash dishes',
      'assignees': ['Ahmad'],
      'due': 'Today',
      'done': false,
    },
    {
      'title': 'Clean kitchen',
      'assignees': ['Lana', 'Mustafa'],
      'due': 'Tomorrow',
      'done': true,
    },
    {
      'title': 'Vacuum hallway',
      'assignees': ['Sama'],
      'due': 'Mar 22',
      'done': false,
    },
    {
      'title': 'Laundry rotation',
      'assignees': ['Ahmad', 'Sama'],
      'due': 'Mar 23',
      'done': false,
    },
    {
      'title': 'Bathroom check',
      'assignees': ['Mustafa'],
      'due': 'Mar 24',
      'done': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final visibleTasks = myTasks
        ? _tasks
            .where(
              (task) => (task['assignees'] as List<String>).contains(_currentUser),
            )
            .toList()
        : _tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: true, label: Text('My Tasks')),
              ButtonSegment<bool>(value: false, label: Text('All Tasks')),
            ],
            selected: <bool>{myTasks},
            onSelectionChanged: (selection) {
              setState(() => myTasks = selection.first);
            },
          ),
          const SizedBox(height: 16),
          ...visibleTasks.map((task) {
            final done = task['done'] as bool;
            return Card(
              child: CheckboxListTile(
                value: done,
                onChanged: (value) {
                  setState(() => task['done'] = value ?? false);
                },
                title: Text(
                  task['title'] as String,
                  style: TextStyle(
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: (task['assignees'] as List<String>)
                          .map((a) => Chip(label: Text(a)))
                          .toList(),
                    ),
                    Text('Due: ${task['due']}'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createTask),
        child: const Icon(Icons.add),
      ),
    );
  }
}
