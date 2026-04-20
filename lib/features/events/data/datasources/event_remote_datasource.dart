import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/event_model.dart';

class EventRemoteDataSource {
  const EventRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<List<EventModel>> getEvents(String householdId) async {
    try {
      final snapshot = await _firestore
          .collection('households')
          .doc(householdId)
          .collection('events')
          .orderBy('eventDate')
          .get();
      return snapshot.docs.map(EventModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load events.', e);
    }
  }

  Future<EventModel> createEvent(
    String householdId, {
    required String title,
    String? description,
    required DateTime eventDate,
    String? eventTime,
    String? location,
    required String eventType,
  }) async {
    try {
      final ref = _firestore
          .collection('households')
          .doc(householdId)
          .collection('events')
          .doc();
      final model = EventModel(
        id: ref.id,
        householdId: householdId,
        title: title,
        description: description,
        eventDate: eventDate,
        eventTime: eventTime,
        location: location,
        eventType: eventType,
        createdBy: _firebaseAuth.currentUser?.uid ?? 'guest',
        createdAt: DateTime.now(),
      );
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      final created = await ref.get();
      final createdModel = EventModel.fromFirestore(created);
      await _createEventNotifications(createdModel);
      return createdModel;
    } on FirebaseException catch (e) {
      throw ApiException('Failed to create event.', e);
    }
  }

  Future<void> deleteEvent(String householdId, String eventId) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('events')
          .doc(eventId)
          .delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete event.', e);
    }
  }

  Future<void> _createEventNotifications(EventModel event) async {
    try {
      final actorId = _firebaseAuth.currentUser?.uid?.trim();
      if (actorId == null || actorId.isEmpty) return;

      final actorName = _firebaseAuth.currentUser?.displayName?.trim();
      final actorEmail = _firebaseAuth.currentUser?.email?.trim();
      final actorLabel = (actorName != null && actorName.isNotEmpty)
          ? actorName
          : (actorEmail != null && actorEmail.isNotEmpty)
              ? actorEmail
              : 'A roommate';

      final householdDoc = await _firestore
          .collection('households')
          .doc(event.householdId)
          .get();
      final householdData = householdDoc.data() ?? const <String, dynamic>{};
      final members = householdData['members'] as List<dynamic>? ?? const [];
      final memberIds = members
          .whereType<Map<String, dynamic>>()
          .map((member) => (member['uid'] as String? ?? '').trim())
          .where((uid) => uid.isNotEmpty && uid != actorId)
          .toSet();

      for (final recipientId in memberIds) {
        final notificationRef = _firestore
            .collection('users')
            .doc(recipientId)
            .collection('notifications')
            .doc();
        await notificationRef.set({
          'id': notificationRef.id,
          'recipientUserId': recipientId,
          'householdId': event.householdId,
          'type': 'event_created',
          'title': '$actorLabel created a new event',
          'body': event.title,
          'isRead': false,
          'referenceId': event.id,
          'referenceType': 'event',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      debugPrint('Event notification fan-out failed: ${e.code} ${e.message}');
    }
  }
}
