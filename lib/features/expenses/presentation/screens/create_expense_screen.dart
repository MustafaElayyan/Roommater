import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  ConsumerState<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _splitAmong = <String>{};
  String? _payer;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Expense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
          final memberNames = members.map((m) => m.displayName).toList();
          _payer ??= memberNames.first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _payer,
                decoration: const InputDecoration(labelText: 'Payer'),
                items: memberNames
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) => setState(() => _payer = value ?? memberNames.first),
              ),
              const SizedBox(height: 12),
              const Text('Split Among'),
              Wrap(
                spacing: 6,
                children: memberNames
                    .map(
                      (member) => FilterChip(
                        label: Text(member),
                        selected: _splitAmong.contains(member),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _splitAmong.add(member);
                            } else {
                              _splitAmong.remove(member);
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
                onPressed: hasSplitMembers ? () => Navigator.of(context).pop() : null,
                child: const Text('Create Expense'),
              ),
            ],
          );
        },
      ),
    );
  }
}
