import 'package:flutter/foundation.dart';

/// Represents a chat conversation between two users.
@immutable
class ChatEntity {
  const ChatEntity({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
