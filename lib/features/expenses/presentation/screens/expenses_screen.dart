import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../domain/entities/expense_entity.dart';
import '../controllers/expense_controller.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final household = ref.watch(currentHouseholdProvider);
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);
    final members = membersAsync.valueOrNull ?? const <MemberEntity>[];

    return Scaffold(
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load expenses: $error')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Amount: ${expense.amount.toStringAsFixed(2)} JOD'),
                      if (expense.category?.isNotEmpty ?? false)
                        Text('Category: ${expense.category}'),
                      Text('Payer: ${_memberName(members, expense.payerId)}'),
                      const SizedBox(height: 8),
                      ...expense.splits.map(
                        (split) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _memberName(members, split.userId),
                          ),
                          subtitle: Text(
                            '${split.shareAmount.toStringAsFixed(2)} JOD',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              split.isSettled
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: split.isSettled ? Colors.green : null,
                            ),
                            onPressed: () {
                              ref
                                  .read(expenseControllerProvider.notifier)
                                  .settleExpense(
                                    expenseId: expense.id,
                                    userId: split.userId,
                                    isSettled: !split.isSettled,
                                  );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createExpense),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _memberName(List<MemberEntity> members, String uid) {
    final match = members.where((m) => m.uid == uid).toList();
    return match.isNotEmpty ? match.first.displayName : uid;
  }
}
