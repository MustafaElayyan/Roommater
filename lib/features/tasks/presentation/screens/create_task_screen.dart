import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../household/domain/entities/member_entity.dart';
import '../../../household/presentation/controllers/household_controller.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key, this.editingTask});

  final TaskEntity? editingTask;

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selectedMemberUids = <String>{};
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSubmitting = false;
  bool _isRepeatable = false;
  final Set<int> _repeatDays = <int>{};

  bool get _isEditing => widget.editingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.editingTask;
    if (task == null) return;
    _titleController.text = task.title;
    _descController.text = task.description ?? '';
    final assigned = task.assignedToUserIds.isNotEmpty
        ? task.assignedToUserIds
        : (task.assignedToUserId == null || task.assignedToUserId!.trim().isEmpty)
            ? const <String>[]
            : <String>[task.assignedToUserId!];
    _selectedMemberUids.addAll(assigned);
    if (task.dueDate != null) {
      _date = task.dueDate;
      _time = TimeOfDay(hour: task.dueDate!.hour, minute: task.dueDate!.minute);
    }
    _repeatDays.addAll(task.repeatDays);
    _isRepeatable = _repeatDays.isNotEmpty;
  }

  void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.tasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<MemberEntity> members) async {
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

    final selectedMembers = members
        .where((member) => _selectedMemberUids.contains(member.uid))
        .toList();
    final assignedToUserIds = selectedMembers.map((m) => m.uid).toList();
    final assignedToNames = selectedMembers.map((m) => m.displayName).toList();
    final firstUid = assignedToUserIds.isNotEmpty ? assignedToUserIds.first : null;
    final firstName = assignedToNames.isNotEmpty ? assignedToNames.first : null;

    if (_isEditing) {
      final task = widget.editingTask!;
      await ref.read(taskControllerProvider.notifier).updateTask(
            taskId: task.id,
            title: _titleController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            isCompleted: task.isCompleted,
            dueDate: dueDate,
            assignedToUserIds: assignedToUserIds,
            assignedToNames: assignedToNames,
            assignedToUserId: firstUid,
            assignedToName: firstName,
            completionNote: task.completionNote,
            repeatDays: _isRepeatable ? _repeatDays.toList() : const [],
            approvalStatus: task.approvalStatus,
          );
    } else {
      await ref.read(taskControllerProvider.notifier).createTask(
            title: _titleController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            dueDate: dueDate,
            assignedToUserIds: assignedToUserIds,
            assignedToNames: assignedToNames,
            assignedToUserId: firstUid,
            assignedToName: firstName,
            repeatDays: _isRepeatable ? _repeatDays.toList() : const [],
          );
    }

    if (!mounted) return;
    final controllerState = ref.read(taskControllerProvider);
    if (controllerState.hasError) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${controllerState.error}')),
      );
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final household = ref.watch(currentHouseholdProvider);
    final membersAsync = household != null
        ? ref.watch(householdMembersProvider(household.id))
        : const AsyncValue<List<MemberEntity>>.data([]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackNavigation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Task' : 'Create Task'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
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
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              Text(
                'Assign Members',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              membersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Failed to load members: $e'),
                data: (members) {
                  if (members.isEmpty) {
                    return const Text('No household members available');
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: members.map((member) {
                      final selected = _selectedMemberUids.contains(member.uid);
                      return FilterChip(
                        label: Text(member.displayName),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedMemberUids.add(member.uid);
                            } else {
                              _selectedMemberUids.remove(member.uid);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
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
                    initialDate: _date ?? DateTime.now(),
                  );
                  if (!mounted) return;
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_time == null ? 'Pick time' : 'Time: ${_time!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time ?? TimeOfDay.now(),
                  );
                  if (!mounted) return;
                  if (picked != null) setState(() => _time = picked);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isRepeatable,
                onChanged: (value) {
                  setState(() {
                    _isRepeatable = value;
                    if (!value) _repeatDays.clear();
                  });
                },
                title: const Text('Repeat task'),
                subtitle: const Text('Choose custom days'),
              ),
              if (_isRepeatable)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRepeatDayChip(1, 'Mon'),
                    _buildRepeatDayChip(2, 'Tue'),
                    _buildRepeatDayChip(3, 'Wed'),
                    _buildRepeatDayChip(4, 'Thu'),
                    _buildRepeatDayChip(5, 'Fri'),
                    _buildRepeatDayChip(6, 'Sat'),
                    _buildRepeatDayChip(7, 'Sun'),
                  ],
                ),
              const SizedBox(height: 24),
              membersAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (members) => FilledButton(
                  onPressed: _isSubmitting ? null : () => _submit(members),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatDayChip(int day, String label) {
    return FilterChip(
      label: Text(label),
      selected: _repeatDays.contains(day),
      onSelected: (value) {
        setState(() {
          if (value) {
            _repeatDays.add(day);
          } else {
            _repeatDays.remove(day);
          }
        });
      },
    );
  }
}
