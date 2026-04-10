import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
      return EventModel.fromFirestore(created);
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
}
