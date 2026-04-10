import '../entities/event_entity.dart';

abstract interface class EventRepository {
  Future<List<EventEntity>> getEvents(String householdId);

  Future<EventEntity> createEvent(
    String householdId, {
    required String title,
    String? description,
    required DateTime eventDate,
    String? eventTime,
    String? location,
    required String eventType,
  });

  Future<void> deleteEvent(String householdId, String eventId);
}
