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

  factory MessageModel.fromJson(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] as String? ?? '',
      chatId: data['chatId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: DateTime.tryParse(data['sentAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
    };
  }
}
