import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      {
        'id': '1',
        'title': 'House Meeting',
        'date': 'Mar 21',
        'time': '7:00 PM',
        'location': 'Living Room',
        'rsvp': '3 Yes • 1 Maybe',
      },
      {
        'id': '2',
        'title': 'Dinner Night',
        'date': 'Mar 22',
        'time': '8:30 PM',
        'location': 'Kitchen',
        'rsvp': '2 Yes • 2 No',
      },
      {
        'id': '3',
        'title': 'Quiet Hours Plan',
        'date': 'Mar 24',
        'time': '6:00 PM',
        'location': 'Group Chat',
        'rsvp': '4 Maybe',
      },
      {
        'id': '4',
        'title': 'Weekend Cleanup',
        'date': 'Mar 26',
        'time': '10:00 AM',
        'location': 'Apartment',
        'rsvp': '4 Yes',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            leading: const Icon(Icons.event),
            title: Text(event['title']!),
            subtitle: Text(
              '${event['date']} • ${event['time']}\n${event['location']} • ${event['rsvp']}',
            ),
            isThreeLine: true,
            onTap: () => context.go(
              AppRoutes.eventDetail.replaceFirst(':id', event['id']!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
    );
  }
}
