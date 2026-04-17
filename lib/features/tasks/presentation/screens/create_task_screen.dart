import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../household/presentation/controllers/household_controller.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../controllers/task_controller.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedMemberUid;
  String? _selectedMemberName;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    DateTime? dueDate;
    if (_date != null) {
      final time = _time ?? const TimeOfDay(hour: 23, minute: 59);
      dueDate = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        time.hour,
        time.minute,
      );
    }

    await ref.read(taskControllerProvider.notifier).createTask(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          dueDate: dueDate,
          assignedToUserId: _selectedMemberUid,
          assignedToName: _selectedMemberName,
        );

    if (!mounted) return;

    final controllerState = ref.read(taskControllerProvider);
    if (controllerState.hasError) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${controllerState.error}')),
      );
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _titleController.clear();
            _descController.clear();
            _selectedMemberUid = null;
            _selectedMemberName = null;
            _date = null;
            _time = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created successfully')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final household = ref.watch(currentHouseholdProvider);
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            membersAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load members: $e'),
              data: (members) => DropdownButtonFormField<String>(
                value: _selectedMemberUid,
                decoration: const InputDecoration(labelText: 'Assign Member'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...members.map(
                    (m) => DropdownMenuItem<String>(
                      value: m.uid,
                      child: Text(m.displayName),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMemberUid = value;
                    String? selectedName;
                    for (final member in members) {
                      if (member.uid == value) {
                        selectedName = member.displayName;
                        break;
                      }
                    }
                    _selectedMemberName = selectedName;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_date == null
                  ? 'Pick date'
                  : 'Date: ${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (!mounted) return;
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_time == null
                  ? 'Pick time'
                  : 'Time: ${_time!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (!mounted) return;
                if (picked != null) setState(() => _time = picked);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
