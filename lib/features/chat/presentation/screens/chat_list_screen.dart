import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/chat_controller.dart';

/// Screen showing the list of ongoing chat conversations.
///
/// Replace the placeholder [_currentUserId] with the real authenticated UID
/// once the auth state provider is wired.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  // TODO(dev): replace with ref.watch(authStateProvider).value?.uid
  static const String _currentUserId = 'placeholder_uid';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider(_currentUserId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(chat.id),
                subtitle: Text(chat.lastMessage ?? ''),
                onTap: () => context.go(
                  AppRoutes.chatRoom.replaceFirst(':id', chat.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
