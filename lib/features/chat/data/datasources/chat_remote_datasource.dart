import '../../../../core/errors/app_exception.dart';
import '../../../../core/local/local_store.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Handles local data calls for chats and messages.
class ChatRemoteDataSource {
  const ChatRemoteDataSource();

  Stream<List<ChatModel>> getChats(String userId) {
    return Stream<List<ChatModel>>.multi((controller) {
      void emit() {
        final chats = LocalStore.chatsById.values
            .where((chat) => chat.participantIds.contains(userId))
            .toList()
          ..sort((a, b) {
            final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
        controller.add(chats);
      }

      emit();
      final sub = LocalStore.chatsChangedController.stream.listen((_) => emit());
      controller.onCancel = sub.cancel;
    }).handleError(
      (Object e) => throw DataStoreException('Failed to load chats.', e),
    );
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return Stream<List<MessageModel>>.multi((controller) {
      void emit() {
        final messages =
            List<MessageModel>.from(LocalStore.messagesByChatId[chatId] ?? const [])
              ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
        controller.add(messages);
      }

      emit();
      final sub = LocalStore.messagesChangedController.stream
          .where((changedChatId) => changedChatId == chatId)
          .listen((_) => emit());
      controller.onCancel = sub.cancel;
    }).handleError(
      (Object e) => throw DataStoreException('Failed to load messages.', e),
    );
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      final stored = MessageModel(
        id: message.id.isNotEmpty ? message.id : LocalStore.nextId('message'),
        chatId: message.chatId,
        senderId: message.senderId,
        text: message.text,
        sentAt: message.sentAt,
      );

      LocalStore.messagesByChatId
          .putIfAbsent(message.chatId, () => [])
          .add(stored);

      final existingChat = LocalStore.chatsById[message.chatId];
      if (existingChat == null) {
        LocalStore.chatsById[message.chatId] = ChatModel(
          id: message.chatId,
          participantIds: [message.senderId],
          lastMessage: message.text,
          lastMessageAt: message.sentAt,
        );
      } else {
        LocalStore.chatsById[message.chatId] = ChatModel(
          id: existingChat.id,
          participantIds: existingChat.participantIds,
          lastMessage: message.text,
          lastMessageAt: message.sentAt,
        );
      }

      LocalStore.messagesChangedController.add(message.chatId);
      LocalStore.chatsChangedController.add(null);
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to send message.', e);
    }
  }
}
