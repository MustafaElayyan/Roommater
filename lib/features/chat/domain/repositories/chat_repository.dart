import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

/// Contract for chat and messaging operations.
abstract interface class ChatRepository {
  /// Returns a real-time stream of chats for [userId].
  Stream<List<ChatEntity>> getChats(String userId);

  /// Returns a real-time stream of messages in [chatId].
  Stream<List<MessageEntity>> getMessages(String chatId);

  /// Sends a [message] in the given chat.
  Future<void> sendMessage(MessageEntity message);
}
