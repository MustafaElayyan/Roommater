import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._dataSource);

  final NotificationRemoteDataSource _dataSource;

  @override
  Stream<List<NotificationEntity>> watchNotifications(String recipientUserId) {
    return _dataSource.watchNotifications(recipientUserId);
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String recipientUserId) {
    return _dataSource.getNotifications(recipientUserId);
  }

  @override
  Future<NotificationEntity> createNotification({
    required String recipientUserId,
    String? householdId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
  }) {
    return _dataSource.createNotification(
      recipientUserId: recipientUserId,
      householdId: householdId,
      type: type,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceType: referenceType,
    );
  }

  @override
  Future<void> markAsRead(String recipientUserId, String notificationId) {
    return _dataSource.markAsRead(recipientUserId, notificationId);
  }
}
