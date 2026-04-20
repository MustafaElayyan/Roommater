import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/expense_model.dart';

class ExpenseRemoteDataSource {
  const ExpenseRemoteDataSource(this._firestore, this._firebaseAuth);

  static const String expenseHistoryAccessDeniedMessage =
      'Only household members can view expense history.';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<List<ExpenseModel>> getExpenses(String householdId) async {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid?.trim();
      if (currentUid == null || currentUid.isEmpty) {
        throw const AuthException('You must be signed in to view expenses.');
      }
      final canViewExpenses = await _canViewExpenseHistory(
        householdId: householdId,
        userId: currentUid,
      );
      if (!canViewExpenses) {
        throw const AuthException(expenseHistoryAccessDeniedMessage);
      }
      final snapshot = await _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(ExpenseModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load expenses.', e);
    }
  }

  Future<ExpenseModel> createExpense(
    String householdId, {
    required String title,
    required double amount,
    String? category,
    required String payerId,
    required List<ExpenseSplitModel> splits,
  }) async {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      if (currentUid == null || currentUid.trim().isEmpty) {
        throw const AuthException('You must be signed in to create expenses.');
      }
      final ref = _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .doc();
      final model = ExpenseModel(
        id: ref.id,
        householdId: householdId,
        title: title,
        amount: amount,
        category: category,
        payerId: payerId,
        createdByUserId: currentUid,
        createdAt: DateTime.now(),
        splits: splits,
      );
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      final created = await ref.get();
      final createdModel = ExpenseModel.fromFirestore(created);
      await _createExpenseNotifications(createdModel);
      return createdModel;
    } on FirebaseException catch (e) {
      throw ApiException('Failed to create expense.', e);
    }
  }

  Future<ExpenseModel> settleExpenseSplit(
    String householdId,
    String expenseId, {
    required String userId,
    required bool isSettled,
  }) async {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid?.trim();
      if (currentUid == null || currentUid.isEmpty) {
        throw const AuthException(
          'You must be signed in to update expense settlement.',
        );
      }
      final canSettle = await _canSettleExpense(
        householdId: householdId,
        userId: currentUid,
      );
      if (!canSettle) {
        throw const AuthException(
          'Only the household owner can mark expenses as paid.',
        );
      }
      final ref = _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .doc(expenseId);
      final doc = await ref.get();
      if (!doc.exists) {
        throw const ApiException('Expense not found.');
      }
      final current = ExpenseModel.fromFirestore(doc);
      final updatedSplits = current.splits
          .map((split) {
            if (split.userId != userId) return split;
            return ExpenseSplitModel(
              userId: split.userId,
              shareAmount: split.shareAmount,
              isSettled: isSettled,
              settledAt: isSettled ? DateTime.now() : null,
            );
          })
          .toList();
      await ref.set({
        'splits': updatedSplits
            .map(
              (split) => ExpenseSplitModel(
                userId: split.userId,
                shareAmount: split.shareAmount,
                isSettled: split.isSettled,
                settledAt: split.settledAt,
              ).toFirestore(),
            )
            .toList(),
        'lastUpdatedBy': currentUid,
      }, SetOptions(merge: true));
      final updated = await ref.get();
      return ExpenseModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update expense settlement.', e);
    }
  }

  Future<void> deleteExpense(String householdId, String expenseId) async {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      if (currentUid == null) {
        throw const ApiException('You must be signed in to delete expenses.');
      }
      final expenseRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .doc(expenseId);
      final doc = await expenseRef.get();
      if (!doc.exists) {
        throw const ApiException('Expense not found.');
      }
      final expense = ExpenseModel.fromFirestore(doc);
      if (expense.createdByUserId != currentUid) {
        throw const AuthException('Only the expense creator can delete this expense.');
      }
      await expenseRef.delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete expense.', e);
    }
  }

  Future<bool> _canViewExpenseHistory({
    required String householdId,
    required String userId,
  }) async {
    final householdDoc = await _firestore.collection('households').doc(householdId).get();
    if (!householdDoc.exists) return false;
    final householdData = householdDoc.data() ?? const <String, dynamic>{};
    final ownerId = (householdData['createdByUserId'] as String? ?? '').trim();
    if (ownerId == userId) return true;

    final members = householdData['members'] as List<dynamic>? ?? const [];
    var isHouseholdMember = false;
    for (final member in members.whereType<Map<String, dynamic>>()) {
      final memberUid = (member['uid'] as String? ?? '').trim();
      if (memberUid != userId) continue;
      isHouseholdMember = true;
      final role = (member['role'] as String? ?? '').toLowerCase().trim();
      if (_isAdminOrOwnerRole(role)) return true;
    }

    if (isHouseholdMember) return true;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? const <String, dynamic>{};
    final possibleRoles = [
      userData['role'],
      userData['householdRole'],
      userData['roleInHousehold'],
    ];
    for (final value in possibleRoles) {
      final role = (value as String? ?? '').toLowerCase().trim();
      if (_isAdminOrOwnerRole(role)) return true;
    }
    return false;
  }

  bool _isAdminOrOwnerRole(String role) {
    return role == 'admin' || role == 'owner';
  }

  Future<bool> _canSettleExpense({
    required String householdId,
    required String userId,
  }) async {
    final householdDoc = await _firestore.collection('households').doc(householdId).get();
    if (!householdDoc.exists) return false;
    final householdData = householdDoc.data() ?? const <String, dynamic>{};
    final ownerId = (householdData['createdByUserId'] as String? ?? '').trim();
    if (ownerId == userId) return true;

    final members = householdData['members'] as List<dynamic>? ?? const [];
    for (final member in members.whereType<Map<String, dynamic>>()) {
      final memberUid = (member['uid'] as String? ?? '').trim();
      if (memberUid != userId) continue;
      final role = (member['role'] as String? ?? '').toLowerCase().trim();
      return _isAdminOrOwnerRole(role);
    }
    return false;
  }

  Future<void> _createExpenseNotifications(ExpenseModel expense) async {
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
          .doc(expense.householdId)
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
          'householdId': expense.householdId,
          'type': 'expense_created',
          'title': '$actorLabel added a new expense',
          'body': '${expense.title} — ${expense.amount.toStringAsFixed(2)} JOD',
          'isRead': false,
          'referenceId': expense.id,
          'referenceType': 'expense',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      debugPrint('Expense notification fan-out failed: ${e.code} ${e.message}');
    }
  }
}
