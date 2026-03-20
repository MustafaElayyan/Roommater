import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _members = ['Ahmad', 'Lana', 'Mustafa', 'Sama'];
  final _selectedMembers = <String>{};
  final _customDays = <String>{};
  DateTime? _date;
  TimeOfDay? _time;
  String _recurrence = 'None';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          const Text('Assign Members'),
          Wrap(
            spacing: 6,
            children: _members
                .map(
                  (member) => FilterChip(
                    label: Text(member),
                    selected: _selectedMembers.contains(member),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMembers.add(member);
                        } else {
                          _selectedMembers.remove(member);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_date == null
                ? 'Pick date'
                : 'Date: ${_date!.year}-${_date!.month}-${_date!.day}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: DateTime.now(),
              );
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
              if (picked != null) setState(() => _time = picked);
            },
          ),
          DropdownButtonFormField<String>(
            value: _recurrence,
            decoration: const InputDecoration(labelText: 'Recurrence'),
            items: const [
              DropdownMenuItem(value: 'None', child: Text('None')),
              DropdownMenuItem(value: 'Daily', child: Text('Daily')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Custom', child: Text('Custom')),
            ],
            onChanged: (value) => setState(() => _recurrence = value ?? 'None'),
          ),
          if (_recurrence == 'Custom') ...[
            const SizedBox(height: 12),
            const Text('Weekdays'),
            Wrap(
              spacing: 6,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (day) => FilterChip(
                      label: Text(day),
                      selected: _customDays.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _customDays.add(day);
                          } else {
                            _customDays.remove(day);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
