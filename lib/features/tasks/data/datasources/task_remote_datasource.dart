import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/task_model.dart';

/// Handles task Firestore reads/writes.
class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<List<TaskModel>> getTasks(
    String householdId, {
    bool? myTasks,
    int? page,
    int? pageSize,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks')
          .orderBy('createdAt', descending: true);

      if (myTasks == true) {
        final uid = _firebaseAuth.currentUser?.uid;
        if (uid != null) {
          query = query.where('assignedToUserId', isEqualTo: uid);
        }
      }

      if (pageSize != null && pageSize > 0) {
        query = query.limit(pageSize);
      }

      final snapshot = await query.get();
      return snapshot.docs.map(TaskModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load tasks.', e);
    }
  }

  Future<TaskModel> createTask(
    String householdId, {
    required String title,
    String? description,
    DateTime? dueDate,
    String? assignedToUserId,
    String? assignedToName,
  }) async {
    try {
      final taskRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks')
          .doc();
      final currentUser = _firebaseAuth.currentUser;
      final model = TaskModel(
        id: taskRef.id,
        householdId: householdId,
        title: title,
        description: description,
        isCompleted: false,
        dueDate: dueDate,
        createdByUserId: currentUser?.uid ?? 'guest',
        createdByName: currentUser?.displayName ?? currentUser?.email,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
        completionNote: null,
        createdAt: DateTime.now(),
      );
      await taskRef.set(model.toFirestore(), SetOptions(merge: true));
      final created = await taskRef.get();
      return TaskModel.fromFirestore(created);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to create task.', e);
    }
  }

  Future<TaskModel> updateTask(
    String householdId,
    String taskId, {
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    String? assignedToUserId,
    String? assignedToName,
    String? completionNote,
  }) async {
    try {
      final taskRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks')
          .doc(taskId);
      await taskRef.set({
        'id': taskId,
        'householdId': householdId,
        'title': title,
        if (description != null) 'description': description else 'description': null,
        'isCompleted': isCompleted,
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!) else 'dueDate': null,
        if (assignedToUserId != null)
          'assignedToUserId': assignedToUserId
        else
          'assignedToUserId': null,
        if (assignedToName != null)
          'assignedToName': assignedToName
        else
          'assignedToName': null,
        if (completionNote != null)
          'completionNote': completionNote
        else if (!isCompleted)
          'completionNote': null,
      }, SetOptions(merge: true));
      final updated = await taskRef.get();
      return TaskModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update task.', e);
    }
  }

  Future<void> deleteTask(String householdId, String taskId) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete task.', e);
    }
  }
}
