import '../../domain/entities/message_entity.dart';

/// Data-layer model for a message record.
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.text,
    required super.sentAt,
  });

  factory MessageModel.fromMap(
      String docId, String chatId, Map<String, dynamic> data) {
    return MessageModel(
      id: docId,
      chatId: chatId,
      senderId: data['senderId'] as String,
      text: data['text'] as String,
      sentAt: DateTime.parse(data['sentAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
    };
  }
}
