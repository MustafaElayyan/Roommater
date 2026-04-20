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

  Stream<List<TaskModel>> watchTasks(
    String householdId, {
    bool? myTasks,
    int? pageSize,
  }) {
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

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map(TaskModel.fromFirestore).toList())
        .transform(
          StreamTransformer<List<TaskModel>, List<TaskModel>>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is FirebaseException) {
                sink.addError(
                  ApiException('Failed to load tasks (${error.code}).', error),
                  stackTrace,
                );
                return;
              }
              sink.addError(error, stackTrace);
            },
          ),
        );
  }

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
      final createdModel = TaskModel.fromFirestore(created);
      await _createTaskAssignmentNotificationIfNeeded(createdModel);
      return createdModel;
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
      final previousDoc = await taskRef.get();
      final previousTask =
          previousDoc.exists ? TaskModel.fromFirestore(previousDoc) : null;
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
      final updatedTask = TaskModel.fromFirestore(updated);
      final assignmentChanged =
          previousTask?.assignedToUserId != updatedTask.assignedToUserId;
      if (assignmentChanged) {
        await _createTaskAssignmentNotificationIfNeeded(updatedTask);
      }
      return updatedTask;
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update task.', e);
    }
  }

  Future<void> deleteTask(String householdId, String taskId) async {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      if (currentUid == null) {
        throw const ApiException('You must be signed in to delete tasks.');
      }
      final taskRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks')
          .doc(taskId);
      final doc = await taskRef.get();
      if (!doc.exists) {
        throw const ApiException('Task not found.');
      }
      final task = TaskModel.fromFirestore(doc);
      if (task.createdByUserId != currentUid) {
        throw const AuthException('Only the task creator can delete this task.');
      }
      await taskRef.delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete task.', e);
    }
  }

  Future<void> _createTaskAssignmentNotificationIfNeeded(TaskModel task) async {
    final assigneeId = task.assignedToUserId?.trim();
    if (assigneeId == null || assigneeId.isEmpty) return;
    if (assigneeId == task.createdByUserId) return;

    final senderName = _firebaseAuth.currentUser?.displayName?.trim();
    final senderEmail = _firebaseAuth.currentUser?.email?.trim();
    final assigner = (senderName != null && senderName.isNotEmpty)
        ? senderName
        : (senderEmail != null && senderEmail.isNotEmpty)
            ? senderEmail
            : task.createdByName?.trim().isNotEmpty == true
                ? task.createdByName!.trim()
                : 'A roommate';

    final notificationRef = _firestore
        .collection('users')
        .doc(assigneeId)
        .collection('notifications')
        .doc();

    await notificationRef.set({
      'id': notificationRef.id,
      'recipientUserId': assigneeId,
      'householdId': task.householdId,
      'type': 'task_assignment',
      'title': '$assigner assigned you a task',
      'body': task.description?.trim().isNotEmpty == true
          ? '${task.title}\n${task.description!.trim()}'
          : task.title,
      'isRead': false,
      'referenceId': task.id,
      'referenceType': 'task',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}
