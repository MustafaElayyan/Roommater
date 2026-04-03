import 'package:flutter/foundation.dart';

/// Domain entity representing a household task.
@immutable
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDate,
    required this.createdByUserId,
    this.assignedToUserId,
    required this.createdAt,
  });

  final String id;
  final String householdId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final String createdByUserId;
  final String? assignedToUserId;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
