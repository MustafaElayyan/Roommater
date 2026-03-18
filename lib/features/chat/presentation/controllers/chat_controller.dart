import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_chats_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

// --- Dependency graph ---

final _chatDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return const ChatRemoteDataSource();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(_chatDataSourceProvider));
});

final _getChatsUseCaseProvider = Provider<GetChatsUseCase>((ref) {
  return GetChatsUseCase(ref.watch(chatRepositoryProvider));
});

final _sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

// --- State ---

/// Emits the real-time list of chats for [userId].
final chatsProvider =
    StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  return ref.watch(_getChatsUseCaseProvider)(userId);
});

/// Emits the real-time list of messages in [chatId].
final messagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  return ref
      .watch(chatRepositoryProvider)
      .getMessages(chatId);
});

// --- Controller ---

class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMessage(MessageEntity message) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_sendMessageUseCaseProvider)(message),
    );
  }
}

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);
