import 'package:flutter/material.dart';

class CreateExpenseScreen extends StatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _members = ['Ahmad', 'Lana', 'Mustafa', 'Sama'];
  final _splitAmong = <String>{};
  String _payer = 'Ahmad';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final hasSplitMembers = _splitAmong.isNotEmpty;
    final split = hasSplitMembers
        ? (amount / _splitAmong.length).toStringAsFixed(2)
        : '0.00';

    return Scaffold(
      appBar: AppBar(title: const Text('Create Expense')),
      body: ListView(
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
            items: _members
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (value) => setState(() => _payer = value ?? _members[0]),
          ),
          const SizedBox(height: 12),
          const Text('Split Among'),
          Wrap(
            spacing: 6,
            children: _members
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
