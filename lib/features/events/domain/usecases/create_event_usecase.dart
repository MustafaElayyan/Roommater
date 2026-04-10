import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class CreateEventUseCase {
  const CreateEventUseCase(this._repository);

  final EventRepository _repository;

  Future<EventEntity> call(
    String householdId, {
    required String title,
    String? description,
    required DateTime eventDate,
    String? eventTime,
    String? location,
    required String eventType,
  }) {
    return _repository.createEvent(
      householdId,
      title: title,
      description: description,
      eventDate: eventDate,
      eventTime: eventTime,
      location: location,
      eventType: eventType,
    );
  }
}
