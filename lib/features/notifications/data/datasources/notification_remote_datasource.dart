import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<NotificationModel>> getNotifications(String recipientUserId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientUserId', isEqualTo: recipientUserId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(NotificationModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load notifications.', e);
    }
  }

  Future<NotificationModel> createNotification({
    required String recipientUserId,
    String? householdId,
    required String type,
    required String title,
    String? body,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      final ref = _firestore.collection('notifications').doc();
      final model = NotificationModel(
        id: ref.id,
        recipientUserId: recipientUserId,
        householdId: householdId,
        type: type,
        title: title,
        body: body,
        isRead: false,
        referenceId: referenceId,
        referenceType: referenceType,
        createdAt: DateTime.now(),
      );
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      final created = await ref.get();
      return NotificationModel.fromFirestore(created);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to create notification.', e);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).set({
        'isRead': true,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ApiException('Failed to mark notification as read.', e);
    }
  }
}
