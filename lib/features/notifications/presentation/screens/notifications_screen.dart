import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../controllers/notification_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load notifications: $error')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return Card(
                child: ListTile(
                  tileColor: item.isRead
                      ? null
                      : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  title: Text(item.title),
                  subtitle: item.body == null ? null : Text(item.body!),
                  trailing: item.isRead
                      ? const Icon(Icons.done_all, size: 18)
                      : const Icon(Icons.mark_email_unread_outlined, size: 18),
                  onTap: item.isRead
                      ? null
                      : () {
                          ref
                              .read(notificationControllerProvider.notifier)
                              .markAsRead(item.id);
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
