import 'package:flutter/foundation.dart';

@immutable
class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.recipientUserId,
    this.householdId,
    required this.type,
    required this.title,
    this.body,
    required this.isRead,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  final String id;
  final String recipientUserId;
  final String? householdId;
  final String type;
  final String title;
  final String? body;
  final bool isRead;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
