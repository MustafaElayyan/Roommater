import 'package:flutter/material.dart';

class ManageMembersScreen extends StatelessWidget {
  const ManageMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const members = ['Ahmad', 'Lana', 'Mustafa', 'Sama'];
    const pending = ['Yousef', 'Nour'];

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Members')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...members.map(
            (member) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(member[0])),
                title: Text(member),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Pending Requests', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...pending.map(
            (name) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: Text(name)),
                    TextButton(onPressed: () {}, child: const Text('Reject')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
