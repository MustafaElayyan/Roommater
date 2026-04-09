import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/listing_model.dart';

/// Handles all listings Firestore operations.
class ListingRemoteDataSource {
  const ListingRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<ListingModel>> getListings({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('listings')
          .orderBy('postedAt', descending: true)
          .limit(limit);

      if (startAfterId != null && startAfterId.isNotEmpty) {
        final startDoc =
            await _firestore.collection('listings').doc(startAfterId).get();
        if (startDoc.exists) {
          query = query.startAfterDocument(startDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs.map(ListingModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load listings.', e);
    }
  }

  Future<ListingModel> getListingById(String id) async {
    try {
      final doc = await _firestore.collection('listings').doc(id).get();
      if (!doc.exists) {
        throw const ApiException('Listing not found.');
      }
      return ListingModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load listing.', e);
    }
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      final docRef = _firestore.collection('listings').doc();
      final data = listing.toFirestore();
      await docRef.set({...data, 'id': docRef.id}, SetOptions(merge: true));
      final created = await docRef.get();
      return ListingModel.fromFirestore(created);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to create listing.', e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection('listings').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete listing.', e);
    }
  }
}
