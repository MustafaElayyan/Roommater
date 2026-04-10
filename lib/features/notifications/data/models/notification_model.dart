import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientUserId,
    super.householdId,
    required super.type,
    required super.title,
    super.body,
    required super.isRead,
    super.referenceId,
    super.referenceType,
    required super.createdAt,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAtRaw = data['createdAt'];
    return NotificationModel(
      id: data['id'] as String? ?? doc.id,
      recipientUserId: data['recipientUserId'] as String? ?? '',
      householdId: data['householdId'] as String?,
      type: data['type'] as String? ?? 'general',
      title: data['title'] as String? ?? '',
      body: data['body'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      referenceId: data['referenceId'] as String?,
      referenceType: data['referenceType'] as String?,
      createdAt: switch (createdAtRaw) {
        Timestamp() => createdAtRaw.toDate(),
        String() => DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'recipientUserId': recipientUserId,
      if (householdId != null) 'householdId': householdId,
      'type': type,
      'title': title,
      if (body != null) 'body': body,
      'isRead': isRead,
      if (referenceId != null) 'referenceId': referenceId,
      if (referenceType != null) 'referenceType': referenceType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
