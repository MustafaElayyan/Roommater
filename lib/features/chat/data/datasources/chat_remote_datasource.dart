import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Handles API calls for chats and messages.
class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Stream<List<ChatModel>> getChats(String userId) {
    return Stream.fromFuture(_fetchChats(userId));
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return Stream.fromFuture(_fetchMessages(chatId));
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _apiClient.postJson(
        'chats/${message.chatId}/messages',
        body: message.toJson(),
      );
    } on AppException catch (e) {
      throw ApiException('Failed to send message.', e);
    }
  }

  Future<List<ChatModel>> _fetchChats(String userId) async {
    try {
      final response = await _apiClient.getJsonList(
        'chats',
        queryParameters: {'userId': userId},
      );
      return response
          .whereType<Map<String, dynamic>>()
          .map(ChatModel.fromJson)
          .toList();
    } on AppException catch (e) {
      throw ApiException('Failed to load chats.', e);
    }
  }

  Future<List<MessageModel>> _fetchMessages(String chatId) async {
    try {
      final response = await _apiClient.getJsonList('chats/$chatId/messages');
      return response
          .whereType<Map<String, dynamic>>()
          .map(MessageModel.fromJson)
          .toList();
    } on AppException catch (e) {
      throw ApiException('Failed to load messages.', e);
    }
  }
}
