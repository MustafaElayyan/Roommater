import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Handles Firestore calls for chats and messages.
class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _chatsCol =>
      _firestore.collection(AppConstants.chatsCollection);

  Stream<List<ChatModel>> getChats(String userId) {
    return _chatsCol
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ChatModel.fromFirestore(d.id, d.data())).toList())
        .handleError(
          (Object e) => throw FirestoreException('Failed to load chats.', e),
        );
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatsCol
        .doc(chatId)
        .collection(AppConstants.messagesSubcollection)
        .orderBy('sentAt')
        .snapshots()
        .map((s) => s.docs
            .map((d) => MessageModel.fromFirestore(d.id, chatId, d.data()))
            .toList())
        .handleError(
          (Object e) =>
              throw FirestoreException('Failed to load messages.', e),
        );
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      final chatRef = _chatsCol.doc(message.chatId);
      await chatRef
          .collection(AppConstants.messagesSubcollection)
          .add(message.toFirestore());
      await chatRef.update({
        'lastMessage': message.text,
        'lastMessageAt': message.sentAt.toIso8601String(),
      });
    } catch (e) {
      throw FirestoreException('Failed to send message.', e);
    }
  }
}
