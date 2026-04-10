import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Handles Firestore calls for chats and messages.
class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatModel.fromFirestore).toList());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc, chatId: chatId))
              .toList(),
        );
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      final chatRef = _firestore.collection('chats').doc(message.chatId);
      final messageRef = chatRef.collection('messages').doc();
      await messageRef.set({
        ...message.toFirestore(),
        'id': messageRef.id,
        'chatId': message.chatId,
      }, SetOptions(merge: true));

      await chatRef.set({
        'id': message.chatId,
        'lastMessage': message.text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'participantIds': FieldValue.arrayUnion([message.senderId]),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ApiException('Failed to send message.', e);
    }
  }
}
