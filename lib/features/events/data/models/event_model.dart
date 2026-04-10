import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.householdId,
    required super.title,
    super.description,
    required super.eventDate,
    super.eventTime,
    super.location,
    required super.eventType,
    required super.createdBy,
    required super.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final eventDateRaw = data['eventDate'];
    final createdAtRaw = data['createdAt'];
    return EventModel(
      id: data['id'] as String? ?? doc.id,
      householdId: data['householdId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      eventDate: switch (eventDateRaw) {
        Timestamp() => eventDateRaw.toDate(),
        String() => DateTime.tryParse(eventDateRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
      eventTime: data['eventTime'] as String?,
      location: data['location'] as String?,
      eventType: data['eventType'] as String? ?? 'other',
      createdBy: data['createdBy'] as String? ?? '',
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
      'householdId': householdId,
      'title': title,
      if (description != null) 'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      if (eventTime != null) 'eventTime': eventTime,
      if (location != null) 'location': location,
      'eventType': eventType,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
