import '../entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String recipientUserId);

  Future<NotificationEntity> createNotification({
    required String recipientUserId,
    String? householdId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
  });

  Future<void> markAsRead(String notificationId);
}
