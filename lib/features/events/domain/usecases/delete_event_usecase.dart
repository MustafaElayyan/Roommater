import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  const DeleteEventUseCase(this._repository);

  final EventRepository _repository;

  Future<void> call(String householdId, String eventId) {
    return _repository.deleteEvent(householdId, eventId);
  }
}
