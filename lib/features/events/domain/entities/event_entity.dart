import 'package:flutter/foundation.dart';

@immutable
class EventEntity {
  static const String defaultEventType = 'meeting';

  const EventEntity({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventTime,
    this.location,
    required this.eventType,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String householdId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? eventTime;
  final String? location;
  final String eventType;
  final String createdBy;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
