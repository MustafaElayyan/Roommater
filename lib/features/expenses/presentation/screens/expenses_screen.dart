import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {
        'title': 'Groceries',
        'amount': '12 JOD',
        'category': 'Food',
        'payer': 'Ahmad',
        'date': 'Mar 20',
      },
      {
        'title': 'Water Bill',
        'amount': '18 JOD',
        'category': 'Utilities',
        'payer': 'Lana',
        'date': 'Mar 18',
      },
      {
        'title': 'Cleaning Supplies',
        'amount': '7 JOD',
        'category': 'Household',
        'payer': 'Mustafa',
        'date': 'Mar 15',
      },
      {
        'title': 'Internet',
        'amount': '24 JOD',
        'category': 'Utilities',
        'payer': 'Sama',
        'date': 'Mar 12',
      },
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('You owe Ahmad'),
              subtitle: const Text('5 JOD'),
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Lana owes you'),
              subtitle: const Text('3 JOD'),
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Text('Expense History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...history.map(
            (entry) => ListTile(
              title: Text(entry['title']!),
              subtitle: Text(
                '${entry['category']} • Paid by ${entry['payer']} • ${entry['date']}',
              ),
              trailing: Text(entry['amount']!),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createExpense),
        child: const Icon(Icons.add),
      ),
    );
  }
}
