import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

/// Handles task Firestore reads/writes.
class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Stream<List<TaskModel>> watchTasks(
    String householdId, {
    bool myTasks = false,
    int? pageSize,
  }) {
    final uid = myTasks ? _firebaseAuth.currentUser?.uid : null;
    if (myTasks && uid == null) return const Stream<List<TaskModel>>.empty();

    Query<Map<String, dynamic>> query = _firestore
        .collection('households')
        .doc(householdId)
        .collection('tasks');

    if (myTasks) {
      query = query.where(
        Filter.or(
          Filter('assignedToUserIds', arrayContains: uid),
          Filter('assignedToUserId', isEqualTo: uid),
        ),
      );
    }

    if (!myTasks) {
      query = query.orderBy('createdAt', descending: true);
    }

    if (!myTasks && pageSize != null && pageSize > 0) {
      query = query.limit(pageSize);
    }

    return query
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map(TaskModel.fromFirestore).toList();
          if (myTasks) {
            tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            if (pageSize != null && pageSize > 0) {
              return tasks.take(pageSize).toList();
            }
          }
          return tasks;
        })
        .transform(
          StreamTransformer<List<TaskModel>, List<TaskModel>>.fromHandlers(
            handleError: (error, stackTrace, sink) {
              if (error is FirebaseException) {
                debugPrint(
                  'Task watch query failed: ${error.code} ${error.message}. '
                  'Returning empty task list.',
                );
                sink.add(const <TaskModel>[]);
                return;
              }
              sink.addError(error, stackTrace);
            },
          ),
        );
  }

  Future<List<TaskModel>> getTasks(
    String householdId, {
    bool myTasks = false,
    int? page,
    int? pageSize,
  }) async {
    try {
      final uid = myTasks ? _firebaseAuth.currentUser?.uid : null;
      if (myTasks && uid == null) return <TaskModel>[];

      Query<Map<String, dynamic>> query = _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks');

      if (myTasks) {
        query = query.where(
          Filter.or(
            Filter('assignedToUserIds', arrayContains: uid),
            Filter('assignedToUserId', isEqualTo: uid),
          ),
        );
      }

      if (!myTasks) {
        query = query.orderBy('createdAt', descending: true);
      }

      if (!myTasks && pageSize != null && pageSize > 0) {
        query = query.limit(pageSize);
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs.map(TaskModel.fromFirestore).toList();
      if (myTasks) {
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (pageSize != null && pageSize > 0) {
          return tasks.take(pageSize).toList();
        }
      }
      return tasks;
    } on FirebaseException catch (e) {
      debugPrint(
        'Task query failed: ${e.code} ${e.message}. Returning empty task list.',
      );
      return <TaskModel>[];
    }
  }

  Future<TaskModel> createTask(
    String householdId, {
    required String title,
    String? description,
    DateTime? dueDate,
    List<String> assignedToUserIds = const [],
    List<String> assignedToNames = const [],
    String? assignedToUserId,
    String? assignedToName,
    List<int> repeatDays = const [],
  }) async {
    try {
      final taskRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('tasks')
          .doc();
      final currentUser = _firebaseAuth.currentUser;
      final normalized = _normalizeAssignments(
        assignedToUserIds: assignedToUserIds,
        assignedToNames: assignedToNames,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
      );
      final isOwner = await _isCurrentUserOwner(householdId);
      final model = TaskModel(
        id: taskRef.id,
        householdId: householdId,
        title: title,
        description: description,
        isCompleted: false,
        dueDate: dueDate,
        createdByUserId: currentUser?.uid ?? 'guest',
        createdByName: currentUser?.displayName ?? currentUser?.email,
        assignedToUserIds: normalized.ids,
        assignedToNames: normalized.names,
        assignedToUserId: normalized.firstId,
        assignedToName: normalized.firstName,
        completionNote: null,
        repeatDays: repeatDays,
        approvalStatus:
            isOwner ? TaskEntity.statusActive : TaskEntity.statusPendingApproval,
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
    List<String> assignedToUserIds = const [],
    List<String> assignedToNames = const [],
    String? assignedToUserId,
    String? assignedToName,
    String? completionNote,
    List<int> repeatDays = const [],
    String? approvalStatus,
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
      final normalized = _normalizeAssignments(
        assignedToUserIds: assignedToUserIds,
        assignedToNames: assignedToNames,
        assignedToUserId: assignedToUserId,
        assignedToName: assignedToName,
      );
      await taskRef.set({
        'id': taskId,
        'householdId': householdId,
        'title': title,
        if (description != null) 'description': description else 'description': null,
        'isCompleted': isCompleted,
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!) else 'dueDate': null,
        'assignedToUserIds': normalized.ids,
        'assignedToNames': normalized.names,
        if (normalized.firstId != null)
          'assignedToUserId': normalized.firstId
        else
          'assignedToUserId': null,
        if (normalized.firstName != null)
          'assignedToName': normalized.firstName
        else
          'assignedToName': null,
        if (completionNote != null)
          'completionNote': completionNote
        else if (!isCompleted)
          'completionNote': null,
        'repeatDays': repeatDays,
        if (approvalStatus != null) 'approvalStatus': approvalStatus,
      }, SetOptions(merge: true));
      final updated = await taskRef.get();
      final updatedTask = TaskModel.fromFirestore(updated);
      final assignmentChanged = !_sameAssignments(
        previousTask?.assignedToUserIds ?? const [],
        updatedTask.assignedToUserIds,
      );
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
      final isOwner = await _isCurrentUserOwner(householdId);
      if (!isOwner && task.createdByUserId != currentUid) {
        throw const AuthException(
          'Only the task creator or household owner can delete this task.',
        );
      }
      await taskRef.delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete task.', e);
    }
  }

  Future<void> _createTaskAssignmentNotificationIfNeeded(TaskModel task) async {
    final assigneeIds = task.assignedToUserIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (assigneeIds.isEmpty) return;

    final senderName = _firebaseAuth.currentUser?.displayName?.trim();
    final senderEmail = _firebaseAuth.currentUser?.email?.trim();
    final assigner = (senderName != null && senderName.isNotEmpty)
        ? senderName
        : (senderEmail != null && senderEmail.isNotEmpty)
            ? senderEmail
            : task.createdByName?.trim().isNotEmpty == true
                ? task.createdByName!.trim()
                : 'A roommate';

    for (final assigneeId in assigneeIds) {
      if (assigneeId == task.createdByUserId) continue;
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
            ? '${task.title} — ${task.description!.trim()}'
            : task.title,
        'isRead': false,
        'referenceId': task.id,
        'referenceType': 'task',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    }
  }

  Future<bool> _isCurrentUserOwner(String householdId) async {
    final currentUid = _firebaseAuth.currentUser?.uid;
    if (currentUid == null) return false;
    final householdDoc =
        await _firestore.collection('households').doc(householdId).get();
    final householdData = householdDoc.data() ?? const <String, dynamic>{};
    final ownerId = householdData['createdByUserId'] as String?;
    return ownerId == currentUid;
  }

  bool _sameAssignments(List<String> left, List<String> right) {
    final leftSet = left.toSet();
    final rightSet = right.toSet();
    return const SetEquality<String>().equals(leftSet, rightSet);
  }

  _NormalizedAssignments _normalizeAssignments({
    required List<String> assignedToUserIds,
    required List<String> assignedToNames,
    required String? assignedToUserId,
    required String? assignedToName,
  }) {
    final normalizedAssignedIds = assignedToUserIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty);
    final uniqueIds = LinkedHashSet<String>.of(normalizedAssignedIds).toList();
    final normalizedAssignedNames = assignedToNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    return _NormalizedAssignments(
      ids: uniqueIds,
      names: normalizedAssignedNames,
      firstId: uniqueIds.isNotEmpty
          ? uniqueIds.first
          : assignedToUserId,
      firstName: normalizedAssignedNames.isNotEmpty
          ? normalizedAssignedNames.first
          : assignedToName,
    );
  }
}

class _NormalizedAssignments {
  const _NormalizedAssignments({
    required this.ids,
    required this.names,
    required this.firstId,
    required this.firstName,
  });

  final List<String> ids;
  final List<String> names;
  final String? firstId;
  final String? firstName;
}
