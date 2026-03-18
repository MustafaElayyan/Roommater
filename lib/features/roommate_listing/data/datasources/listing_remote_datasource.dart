import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/listing_model.dart';

/// Handles all Firestore calls related to listings.
class ListingRemoteDataSource {
  const ListingRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.listingsCollection);

  Future<List<ListingModel>> getListings({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _col.where('isAvailable', isEqualTo: true).limit(limit);
      if (startAfterId != null) {
        final snapshot = await _col.doc(startAfterId).get();
        query = query.startAfterDocument(snapshot);
      }
      final result = await query.get();
      return result.docs
          .map((d) => ListingModel.fromFirestore(d.id, d.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to load listings.', e);
    }
  }

  Future<ListingModel> getListingById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) {
        throw const FirestoreException('Listing not found.');
      }
      return ListingModel.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      throw FirestoreException('Failed to load listing.', e);
    }
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      final ref = await _col.add(listing.toFirestore());
      return ListingModel.fromFirestore(ref.id, listing.toFirestore());
    } catch (e) {
      throw FirestoreException('Failed to create listing.', e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _col.doc(id).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete listing.', e);
    }
  }
}
