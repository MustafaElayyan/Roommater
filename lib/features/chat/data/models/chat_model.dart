import '../../domain/entities/chat_entity.dart';

/// Data-layer model for a Firestore chat document.
class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantIds,
    super.lastMessage,
    super.lastMessageAt,
  });

  factory ChatModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return ChatModel(
      id: docId,
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.parse(data['lastMessageAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null)
        'lastMessageAt': lastMessageAt!.toIso8601String(),
    };
  }
}
