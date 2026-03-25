import '../../domain/entities/chat_entity.dart';

/// Data-layer model for a chat payload.
class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantIds,
    super.lastMessage,
    super.lastMessageAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> data) {
    return ChatModel(
      id: data['id'] as String? ?? '',
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.tryParse(data['lastMessageAt'] as String? ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null)
        'lastMessageAt': lastMessageAt!.toIso8601String(),
    };
  }
}
