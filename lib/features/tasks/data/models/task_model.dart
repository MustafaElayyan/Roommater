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
    super.assignedToUserId,
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
      assignedToUserId: data['assignedToUserId'] as String?,
      createdAt: DateTime.parse(
        data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
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
      if (assignedToUserId != null) 'assignedToUserId': assignedToUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
