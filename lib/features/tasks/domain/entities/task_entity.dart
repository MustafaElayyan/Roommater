import 'package:flutter/foundation.dart';

/// Domain entity representing a household task.
@immutable
class TaskEntity {
  static const String statusActive = 'active';
  static const String statusPendingApproval = 'pending_approval';

  const TaskEntity({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDate,
    required this.createdByUserId,
    this.createdByName,
    this.assignedToUserIds = const [],
    this.assignedToNames = const [],
    this.assignedToUserId,
    this.assignedToName,
    this.completionNote,
    this.repeatDays = const [],
    this.approvalStatus = statusActive,
    required this.createdAt,
  });

  final String id;
  final String householdId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final String createdByUserId;
  final String? createdByName;
  final List<String> assignedToUserIds;
  final List<String> assignedToNames;
  final String? assignedToUserId;
  final String? assignedToName;
  final String? completionNote;
  final List<int> repeatDays;
  final String approvalStatus;
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
