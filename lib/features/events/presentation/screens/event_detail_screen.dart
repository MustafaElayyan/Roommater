import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../controllers/event_controller.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.events),
        ),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load event: $error')),
        data: (events) {
          final matches = events.where((e) => e.id == eventId).toList();
          if (matches.isEmpty) {
            return const Center(child: Text('Event not found.'));
          }
          final event = matches.first;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Date: ${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}',
                ),
                if (event.eventTime != null) Text('Time: ${event.eventTime}'),
                if (event.location != null) Text('Location: ${event.location}'),
                Text('Type: ${event.eventType}'),
                if (event.description != null) ...[
                  const SizedBox(height: 8),
                  Text(event.description!),
                ],
                const SizedBox(height: 24),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await ref
                        .read(eventControllerProvider.notifier)
                        .deleteEvent(event.id);
                    if (!context.mounted) return;
                    final state = ref.read(eventControllerProvider);
                    if (state.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.error}')),
                      );
                      return;
                    }
                    context.go(AppRoutes.events);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Event'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
