import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  const DeleteEventUseCase(this._repository);

  final EventRepository _repository;

  Future<void> call(String eventId) {
    return _repository.deleteEvent(eventId);
  }
}
