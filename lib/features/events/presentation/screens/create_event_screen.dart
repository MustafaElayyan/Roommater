import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/event_controller.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  static const String _kDefaultEventType = 'meeting';
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    _date = null;
    _time = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
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
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Title is required'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
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
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final eventTime = _time == null
        ? null
        : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';
    await ref.read(eventControllerProvider.notifier).createEvent(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          eventDate: _date!,
          eventTime: eventTime,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          eventType: _kDefaultEventType,
        );

    if (!mounted) return;
    final state = ref.read(eventControllerProvider);
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
          const SnackBar(content: Text('Event created successfully')),
        );
      }
    }
  }
}
