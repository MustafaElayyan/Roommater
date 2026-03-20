import 'package:flutter/material.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String rsvp = 'Yes';

  @override
  Widget build(BuildContext context) {
    final members = [
      {'name': 'Ahmad', 'status': Icons.check_circle, 'color': Colors.green},
      {'name': 'Lana', 'status': Icons.cancel, 'color': Colors.red},
      {'name': 'Mustafa', 'status': Icons.help, 'color': Colors.orange},
      {'name': 'Sama', 'status': Icons.check_circle, 'color': Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Event Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('House Meeting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Discuss weekly chores and upcoming plans.'),
          const SizedBox(height: 8),
          const Text('Mar 21 • 7:00 PM • Living Room'),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(value: 'Yes', label: Text('Yes')),
              ButtonSegment<String>(value: 'No', label: Text('No')),
              ButtonSegment<String>(value: 'Maybe', label: Text('Maybe')),
            ],
            selected: <String>{rsvp},
            onSelectionChanged: (selection) {
              setState(() => rsvp = selection.first);
            },
          ),
          const SizedBox(height: 16),
          ...members.map(
            (member) => ListTile(
              leading: CircleAvatar(child: Text((member['name']! as String)[0])),
              title: Text(member['name']! as String),
              trailing: Icon(
                member['status']! as IconData,
                color: member['color']! as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
