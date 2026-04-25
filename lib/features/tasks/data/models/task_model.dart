import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';

/// Data-layer model for a task payload.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.householdId,
    required super.title,
    super.description,
    required super.isCompleted,
    super.dueDate,
    required super.createdByUserId,
    super.createdByName,
    super.assignedToUserIds,
    super.assignedToNames,
    super.assignedToUserId,
    super.assignedToName,
    super.completionNote,
    super.repeatDays,
    super.approvalStatus,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> data) {
    final legacyAssignedUid = data['assignedToUserId'] as String?;
    final legacyAssignedName = data['assignedToName'] as String?;
    final assignedToUserIds = _stringList(data['assignedToUserIds']);
    final assignedToNames = _stringList(data['assignedToNames']);
    return TaskModel(
      id: data['id'] as String? ?? '',
      householdId: data['householdId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'] as String)
          : null,
      createdByUserId: data['createdByUserId'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
      assignedToUserIds: assignedToUserIds.isNotEmpty
          ? assignedToUserIds
          : (legacyAssignedUid == null || legacyAssignedUid.isEmpty)
              ? const []
              : [legacyAssignedUid],
      assignedToNames: assignedToNames.isNotEmpty
          ? assignedToNames
          : (legacyAssignedName == null || legacyAssignedName.isEmpty)
              ? const []
              : [legacyAssignedName],
      assignedToUserId: legacyAssignedUid,
      assignedToName: legacyAssignedName,
      completionNote: data['completionNote'] as String?,
      repeatDays: _intList(data['repeatDays']),
      approvalStatus:
          data['approvalStatus'] as String? ?? TaskEntity.statusActive,
      createdAt: DateTime.parse(
        data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory TaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final dueDateRaw = data['dueDate'];
    final createdAtRaw = data['createdAt'];
    final legacyAssignedUid = data['assignedToUserId'] as String?;
    final legacyAssignedName = data['assignedToName'] as String?;
    final assignedToUserIds = _stringList(data['assignedToUserIds']);
    final assignedToNames = _stringList(data['assignedToNames']);

    return TaskModel(
      id: data['id'] as String? ?? doc.id,
      householdId: data['householdId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      dueDate: switch (dueDateRaw) {
        Timestamp() => dueDateRaw.toDate(),
        String() => DateTime.tryParse(dueDateRaw),
        _ => null,
      },
      createdByUserId: data['createdByUserId'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
      assignedToUserIds: assignedToUserIds.isNotEmpty
          ? assignedToUserIds
          : (legacyAssignedUid == null || legacyAssignedUid.isEmpty)
              ? const []
              : [legacyAssignedUid],
      assignedToNames: assignedToNames.isNotEmpty
          ? assignedToNames
          : (legacyAssignedName == null || legacyAssignedName.isEmpty)
              ? const []
              : [legacyAssignedName],
      assignedToUserId: legacyAssignedUid,
      assignedToName: legacyAssignedName,
      completionNote: data['completionNote'] as String?,
      repeatDays: _intList(data['repeatDays']),
      approvalStatus:
          data['approvalStatus'] as String? ?? TaskEntity.statusActive,
      createdAt: switch (createdAtRaw) {
        Timestamp() => createdAtRaw.toDate(),
        String() => DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'title': title,
      if (description != null) 'description': description,
      'isCompleted': isCompleted,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'createdByUserId': createdByUserId,
      if (createdByName != null) 'createdByName': createdByName,
      if (assignedToUserIds.isNotEmpty) 'assignedToUserIds': assignedToUserIds,
      if (assignedToNames.isNotEmpty) 'assignedToNames': assignedToNames,
      if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
      if (assignedToName != null) 'assignedToName': assignedToName,
      if (completionNote != null) 'completionNote': completionNote,
      if (repeatDays.isNotEmpty) 'repeatDays': repeatDays,
      'approvalStatus': approvalStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'householdId': householdId,
      'title': title,
      if (description != null) 'description': description,
      'isCompleted': isCompleted,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      'createdByUserId': createdByUserId,
      if (createdByName != null) 'createdByName': createdByName,
      if (assignedToUserIds.isNotEmpty) 'assignedToUserIds': assignedToUserIds,
      if (assignedToNames.isNotEmpty) 'assignedToNames': assignedToNames,
      if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
      if (assignedToName != null) 'assignedToName': assignedToName,
      if (completionNote != null) 'completionNote': completionNote,
      if (repeatDays.isNotEmpty) 'repeatDays': repeatDays,
      'approvalStatus': approvalStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static List<String> _stringList(dynamic raw) {
    return (raw as List<dynamic>? ?? const [])
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  static List<int> _intList(dynamic raw) {
    return (raw as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((e) => e.toInt())
        .toList();
  }
}
