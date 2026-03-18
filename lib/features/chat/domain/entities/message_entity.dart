import 'package:flutter/foundation.dart';

/// Represents a single message in a chat room.
@immutable
class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime sentAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
