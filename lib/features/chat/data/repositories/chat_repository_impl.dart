import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';

/// Firebase-backed implementation of [ChatRepository].
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._dataSource);

  final ChatRemoteDataSource _dataSource;

  @override
  Stream<List<ChatEntity>> getChats(String userId) {
    return _dataSource.getChats(userId);
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _dataSource.getMessages(chatId);
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    return _dataSource.sendMessage(
      MessageModel(
        id: message.id,
        chatId: message.chatId,
        senderId: message.senderId,
        text: message.text,
        sentAt: message.sentAt,
      ),
    );
  }
}
