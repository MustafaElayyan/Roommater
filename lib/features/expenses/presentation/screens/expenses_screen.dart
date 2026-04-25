import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../domain/entities/expense_entity.dart';
import '../controllers/expense_controller.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;
    final household = ref.watch(currentHouseholdProvider);
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);
    final members = membersAsync.valueOrNull ?? const <MemberEntity>[];
    final userCanSettleExpenses = currentUid != null &&
        household != null &&
        (currentUid == household.createdByUserId ||
            _isAdminOrOwnerRole(_memberRole(members, currentUid)));
    final accessDenied = expensesAsync.hasError &&
        _isExpenseHistoryAccessDenied(expensesAsync.error);

    return Scaffold(
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          final denied = _isExpenseHistoryAccessDenied(error);
          if (denied) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 42),
                    SizedBox(height: 12),
                    Text(
                      'Only household members can view expense history.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('Failed to load expenses: $error'));
        },
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final userCanDeleteExpense = currentUid != null &&
                  expense.createdByUserId == currentUid;
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
                      _memberProfileLink(
                        members: members,
                        uid: expense.payerId,
                        label: 'Payer',
                      ),
                      if (userCanDeleteExpense)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDeleteExpense(context, ref, expense),
                          ),
                        ),
                      const SizedBox(height: 8),
                      ...expense.splits.map(
                        (split) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: UserAvatar(
                            photoUrl: _memberPhotoUrl(members, split.userId),
                            displayName: _memberName(members, split.userId),
                            radius: 12,
                          ),
                          title: Text(_memberName(members, split.userId)),
                          subtitle: Text(
                            '${split.shareAmount.toStringAsFixed(2)} JOD',
                          ),
                          trailing: userCanSettleExpenses
                              ? IconButton(
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
                                )
                              : null,
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
      floatingActionButton: accessDenied
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.createExpense),
              child: const Icon(Icons.add),
            ),
    );
  }

  String _memberName(List<MemberEntity> members, String uid) {
    final match = members.where((m) => m.uid == uid).toList();
    return match.isNotEmpty ? match.first.displayName : uid;
  }

  String? _memberPhotoUrl(List<MemberEntity> members, String uid) {
    final match = members.where((m) => m.uid == uid).toList();
    return match.isNotEmpty ? match.first.photoUrl : null;
  }

  String _memberRole(List<MemberEntity> members, String uid) {
    for (final member in members) {
      if (member.uid == uid) return member.role;
    }
    return 'member';
  }

  Widget _memberProfileLink(
    {
    required List<MemberEntity> members,
    required String uid,
    required String label,
  }) {
    final memberName = _memberName(members, uid);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            photoUrl: _memberPhotoUrl(members, uid),
            displayName: memberName,
            radius: 10,
          ),
          const SizedBox(width: 6),
          Text('$label: $memberName'),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    WidgetRef ref,
    ExpenseEntity expense,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Delete "${expense.title}"?'),
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
    await ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
  }

  bool _isExpenseHistoryAccessDenied(Object? error) {
    if (error is! AuthException) return false;
    return error.message == 'Only household members can view expense history.';
  }

  bool _isAdminOrOwnerRole(String role) {
    final normalized = role.toLowerCase().trim();
    return normalized == 'admin' || normalized == 'owner';
  }
}
