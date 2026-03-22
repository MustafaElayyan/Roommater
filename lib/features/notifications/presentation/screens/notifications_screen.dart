import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Task Reminder',
      'body': 'Wash dishes is due in 1 hour',
      'time': '5m ago',
      'icon': Icons.check_circle_outline,
      'unread': true,
    },
    {
      'title': 'Event Update',
      'body': 'House Meeting time changed to 7:30 PM',
      'time': '18m ago',
      'icon': Icons.event,
      'unread': true,
    },
    {
      'title': 'Expense Added',
      'body': 'Ahmad added Grocery expense',
      'time': '1h ago',
      'icon': Icons.account_balance_wallet_outlined,
      'unread': false,
    },
    {
      'title': 'Request Accepted',
      'body': 'Your household join request was accepted',
      'time': '2h ago',
      'icon': Icons.group_add_outlined,
      'unread': false,
    },
    {
      'title': 'Task Completed',
      'body': 'Lana completed Bathroom check',
      'time': '3h ago',
      'icon': Icons.task_alt,
      'unread': false,
    },
    {
      'title': 'Quiet Hours',
      'body': 'Quiet hours start at 11:00 PM',
      'time': '6h ago',
      'icon': Icons.nights_stay_outlined,
      'unread': false,
    },
    {
      'title': 'Grocery Item',
      'body': 'Milk was marked as purchased',
      'time': '1d ago',
      'icon': Icons.shopping_cart_outlined,
      'unread': false,
    },
    {
      'title': 'Member Joined',
      'body': 'Sama joined your household',
      'time': '2d ago',
      'icon': Icons.person_add_alt,
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            color: item['unread'] as bool
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : null,
            child: ListTile(
              leading: Icon(item['icon'] as IconData),
              title: Text(item['title'] as String),
              subtitle: Text('${item['body']}\n${item['time']}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
