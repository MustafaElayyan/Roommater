import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  const EventRepositoryImpl(this._dataSource);

  final EventRemoteDataSource _dataSource;

  @override
  Future<List<EventEntity>> getEvents(String householdId) {
    return _dataSource.getEvents(householdId);
  }

  @override
  Future<EventEntity> createEvent(
    String householdId, {
    required String title,
    String? description,
    required DateTime eventDate,
    String? eventTime,
    String? location,
    required String eventType,
  }) {
    return _dataSource.createEvent(
      householdId,
      title: title,
      description: description,
      eventDate: eventDate,
      eventTime: eventTime,
      location: location,
      eventType: eventType,
    );
  }

  @override
  Future<void> deleteEvent(String eventId) {
    return _dataSource.deleteEvent(eventId);
  }
}
