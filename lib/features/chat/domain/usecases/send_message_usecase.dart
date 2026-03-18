import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case: send a message in a chat room.
class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<void> call(MessageEntity message) {
    return _repository.sendMessage(message);
  }
}
