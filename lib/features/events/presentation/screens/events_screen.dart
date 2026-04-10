import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../domain/entities/event_entity.dart';
import '../controllers/event_controller.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load events: $error')),
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                child: ListTile(
                  onTap: () => context.go('/events/${event.id}'),
                  title: Text(event.title),
                  subtitle: Text(_subtitle(event)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _subtitle(EventEntity event) {
    final date =
        '${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}';
    final time = event.eventTime == null ? '' : ' • ${event.eventTime}';
    return '$date$time • ${event.eventType}';
  }
}
