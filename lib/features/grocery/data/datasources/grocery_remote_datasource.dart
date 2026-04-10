import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/grocery_item_model.dart';

class GroceryRemoteDataSource {
  const GroceryRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Stream<List<GroceryItemModel>> watchItems(
    String householdId, {
    required bool isPurchased,
  }) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('groceries')
        .where('isPurchased', isEqualTo: isPurchased)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(GroceryItemModel.fromFirestore).toList())
        .handleError((error) {
          if (error is FirebaseException) {
            throw ApiException('Failed to load groceries.', error);
          }
          if (error is Exception) {
            throw ApiException('Failed to load groceries.', error);
          }
          throw ApiException(
            'Failed to load groceries.',
            Exception(error.toString()),
          );
        });
  }

  Future<void> addItem(
    String householdId, {
    required String name,
    required int quantity,
  }) async {
    try {
      final ref = _firestore
          .collection('households')
          .doc(householdId)
          .collection('groceries')
          .doc();
      final item = GroceryItemModel(
        id: ref.id,
        name: name,
        quantity: quantity,
        addedBy: _firebaseAuth.currentUser?.uid ?? 'guest',
        isPurchased: false,
        purchasedBy: null,
        purchasedAt: null,
        householdId: householdId,
        createdAt: DateTime.now(),
      );
      await ref.set(item.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ApiException('Failed to add grocery item.', e);
    }
  }

  Future<void> togglePurchased(
    String householdId,
    String itemId, {
    required bool isPurchased,
  }) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('groceries')
          .doc(itemId)
          .set({
        'isPurchased': isPurchased,
        'purchasedBy': isPurchased ? _firebaseAuth.currentUser?.uid : null,
        'purchasedAt': isPurchased ? FieldValue.serverTimestamp() : null,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update grocery item.', e);
    }
  }

  Future<void> deleteItem(String householdId, String itemId) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('groceries')
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete grocery item.', e);
    }
  }
}
