import 'package:flutter/foundation.dart';

@immutable
class ExpenseSplitEntity {
  const ExpenseSplitEntity({
    required this.userId,
    required this.shareAmount,
    required this.isSettled,
    this.settledAt,
  });

  final String userId;
  final double shareAmount;
  final bool isSettled;
  final DateTime? settledAt;
}

@immutable
class ExpenseEntity {
  const ExpenseEntity({
    required this.id,
    required this.householdId,
    required this.title,
    required this.amount,
    this.category,
    required this.payerId,
    required this.createdAt,
    required this.splits,
  });

  final String id;
  final String householdId;
  final String title;
  final double amount;
  final String? category;
  final String payerId;
  final DateTime createdAt;
  final List<ExpenseSplitEntity> splits;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
