import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case: listen to the list of chats for a given user.
class GetChatsUseCase {
  const GetChatsUseCase(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatEntity>> call(String userId) {
    return _repository.getChats(userId);
  }
}
