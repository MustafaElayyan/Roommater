import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_entity.dart';

/// Data-layer model for a message payload.
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.text,
    required super.sentAt,
  });

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? chatId,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final sentAtRaw = data['sentAt'];
    return MessageModel(
      id: data['id'] as String? ?? doc.id,
      chatId: data['chatId'] as String? ?? chatId ?? '',
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: switch (sentAtRaw) {
        Timestamp() => sentAtRaw.toDate(),
        String() =>
          DateTime.tryParse(sentAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0),
        _ => DateTime.fromMillisecondsSinceEpoch(0),
      },
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}
