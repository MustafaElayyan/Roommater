import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../domain/entities/event_entity.dart';
import '../controllers/event_controller.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load events: $error')),
        data: (events) {
          final selectedEvents = _eventsForDay(events, _selectedDay);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: CalendarDatePicker(
                  initialDate: _selectedDay,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  onDateChanged: (date) => setState(() => _selectedDay = date),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Events on ${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (selectedEvents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No events for selected day'),
                  ),
                )
              else
                ...selectedEvents.map(
                  (event) => Card(
                    child: ListTile(
                      onTap: () => context.go('/events/${event.id}'),
                      title: Text(event.title),
                      subtitle: Text(_subtitle(event)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<EventEntity> _eventsForDay(List<EventEntity> events, DateTime day) {
    final selectedYear = day.year;
    final selectedMonth = day.month;
    final selectedDay = day.day;
    return events.where((event) {
      final date = event.eventDate;
      return date.year == selectedYear &&
          date.month == selectedMonth &&
          date.day == selectedDay;
    }).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  String _subtitle(EventEntity event) {
    final date =
        '${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}';
    final time = event.eventTime == null ? '' : ' • ${event.eventTime}';
    return '$date$time';
  }
}
