import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_entity.dart';

/// Data-layer model for a chat payload.
class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantIds,
    super.lastMessage,
    super.lastMessageAt,
  });

  factory ChatModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final lastMessageAtRaw = data['lastMessageAt'];
    return ChatModel(
      id: data['id'] as String? ?? doc.id,
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: switch (lastMessageAtRaw) {
        Timestamp() => lastMessageAtRaw.toDate(),
        String() => DateTime.tryParse(lastMessageAtRaw),
        _ => null,
      },
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'participantIds': participantIds,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null) 'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
    };
  }
}
