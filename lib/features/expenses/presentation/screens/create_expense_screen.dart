import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/expense_entity.dart';
import '../controllers/expense_controller.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  ConsumerState<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _splitAmong = <String>{};
  bool _isSubmitting = false;

  void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.expenses);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _amountController.clear();
    _categoryController.clear();
    _splitAmong.clear();
  }

  @override
  Widget build(BuildContext context) {
    final household = ref.watch(currentHouseholdProvider);
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final hasSplitMembers = _splitAmong.isNotEmpty;
    final split = hasSplitMembers
        ? (amount / _splitAmong.length).toStringAsFixed(2)
        : '0.00';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Expense'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
          ),
        ),
        body: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Failed to load members: $error')),
          data: (members) {
            if (members.isEmpty) {
              return const Center(
                child: Text('No members found. Join or create a household first.'),
              );
            }
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              const Text('Split Among'),
              Wrap(
                spacing: 6,
                children: members
                    .map(
                      (member) => FilterChip(
                        label: Text(member.displayName),
                        selected: _splitAmong.contains(member.uid),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _splitAmong.add(member.uid);
                            } else {
                              _splitAmong.remove(member.uid);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                hasSplitMembers
                    ? 'Each person pays: $split JOD'
                    : 'Select at least one member for split.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: hasSplitMembers && !_isSubmitting
                    ? () => _submit(context, members)
                    : null,
                child: const Text('Create Expense'),
              ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, List<MemberEntity> members) async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    if (_splitAmong.isEmpty) return;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    setState(() => _isSubmitting = true);
    final currentUserId = ref.read(authStateProvider).valueOrNull?.uid;
    final eachShare = amount / _splitAmong.length;
    final splits = _splitAmong
        .map(
          (uid) => ExpenseSplitEntity(
            userId: uid,
            shareAmount: eachShare,
            isSettled: false,
            settledAt: null,
          ),
        )
        .toList();

    final payerId = currentUserId ?? members.first.uid;
    await ref.read(expenseControllerProvider.notifier).createExpense(
          title: _titleController.text.trim(),
          amount: amount,
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
          payerId: payerId,
          splits: splits,
        );

    if (!mounted) return;
    final state = ref.read(expenseControllerProvider);
    if (state.hasError) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _resetForm();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense created successfully')),
        );
      }
    }
  }
}
