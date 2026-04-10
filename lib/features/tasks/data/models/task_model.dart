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
    super.assignedToUserId,
    super.assignedToName,
    super.completionNote,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> data) {
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
      assignedToUserId: data['assignedToUserId'] as String?,
      assignedToName: data['assignedToName'] as String?,
      completionNote: data['completionNote'] as String?,
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
      assignedToUserId: data['assignedToUserId'] as String?,
      assignedToName: data['assignedToName'] as String?,
      completionNote: data['completionNote'] as String?,
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
      if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
      if (assignedToName != null) 'assignedToName': assignedToName,
      if (completionNote != null) 'completionNote': completionNote,
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
      if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
      if (assignedToName != null) 'assignedToName': assignedToName,
      if (completionNote != null) 'completionNote': completionNote,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
