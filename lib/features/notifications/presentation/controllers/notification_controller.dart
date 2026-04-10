import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/create_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

final _notificationDataSourceProvider = Provider<NotificationRemoteDataSource>((
  ref,
) {
  return NotificationRemoteDataSource(ref.watch(firestoreProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(_notificationDataSourceProvider));
});

final _getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final _createNotificationUseCaseProvider = Provider<CreateNotificationUseCase>((
  ref,
) {
  return CreateNotificationUseCase(ref.watch(notificationRepositoryProvider));
});

final _markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));
});

final notificationsProvider = FutureProvider<List<NotificationEntity>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  if (userId == null) return [];
  return ref.watch(_getNotificationsUseCaseProvider)(userId);
});

class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_markNotificationReadUseCaseProvider)(notificationId);
      ref.invalidate(notificationsProvider);
    });
  }

  Future<void> createNotification({
    required String recipientUserId,
    String? householdId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(_createNotificationUseCaseProvider)(
            recipientUserId: recipientUserId,
            householdId: householdId,
            type: type,
            title: title,
            body: body,
            referenceId: referenceId,
            referenceType: referenceType,
          );
      ref.invalidate(notificationsProvider);
    });
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(
  NotificationController.new,
);
