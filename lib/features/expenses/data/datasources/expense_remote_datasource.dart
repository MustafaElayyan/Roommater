import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/expense_model.dart';

class ExpenseRemoteDataSource {
  const ExpenseRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<List<ExpenseModel>> getExpenses(String householdId) async {
    try {
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
        createdAt: DateTime.now(),
        splits: splits,
      );
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      final created = await ref.get();
      return ExpenseModel.fromFirestore(created);
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
        'lastUpdatedBy': _firebaseAuth.currentUser?.uid,
      }, SetOptions(merge: true));
      final updated = await ref.get();
      return ExpenseModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update expense settlement.', e);
    }
  }

  Future<void> deleteExpense(String householdId, String expenseId) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete expense.', e);
    }
  }
}
