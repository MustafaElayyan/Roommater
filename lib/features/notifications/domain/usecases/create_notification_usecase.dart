import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class CreateNotificationUseCase {
  const CreateNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  Future<NotificationEntity> call({
    required String recipientUserId,
    String? householdId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
  }) {
    return _repository.createNotification(
      recipientUserId: recipientUserId,
      householdId: householdId,
      type: type,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceType: referenceType,
    );
  }
}
