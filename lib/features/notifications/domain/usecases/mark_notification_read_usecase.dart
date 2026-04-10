import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call(String recipientUserId, String notificationId) {
    return _repository.markAsRead(recipientUserId, notificationId);
  }
}
