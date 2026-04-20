import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense_entity.dart';

class ExpenseSplitModel extends ExpenseSplitEntity {
  const ExpenseSplitModel({
    required super.userId,
    required super.shareAmount,
    required super.isSettled,
    super.settledAt,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> data) {
    final settledAtRaw = data['settledAt'];
    return ExpenseSplitModel(
      userId: data['userId'] as String? ?? '',
      shareAmount: (data['shareAmount'] as num?)?.toDouble() ?? 0,
      isSettled: data['isSettled'] as bool? ?? false,
      settledAt: switch (settledAtRaw) {
        String() => DateTime.tryParse(settledAtRaw),
        _ => null,
      },
    );
  }

  factory ExpenseSplitModel.fromFirestore(Map<String, dynamic> data) {
    final settledAtRaw = data['settledAt'];
    return ExpenseSplitModel(
      userId: data['userId'] as String? ?? '',
      shareAmount: (data['shareAmount'] as num?)?.toDouble() ?? 0,
      isSettled: data['isSettled'] as bool? ?? false,
      settledAt: switch (settledAtRaw) {
        Timestamp() => settledAtRaw.toDate(),
        String() => DateTime.tryParse(settledAtRaw),
        _ => null,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shareAmount': shareAmount,
      'isSettled': isSettled,
      if (settledAt != null) 'settledAt': settledAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'shareAmount': shareAmount,
      'isSettled': isSettled,
      if (settledAt != null) 'settledAt': Timestamp.fromDate(settledAt!),
    };
  }
}

class ExpenseModel extends ExpenseEntity {
  static const String unknownCreatorId = '__unknown_creator__';

  const ExpenseModel({
    required super.id,
    required super.householdId,
    required super.title,
    required super.amount,
    super.category,
    required super.payerId,
    required super.createdByUserId,
    required super.createdAt,
    required super.splits,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    return ExpenseModel(
      id: data['id'] as String? ?? '',
      householdId: data['householdId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String?,
      payerId: data['payerId'] as String? ?? '',
      createdByUserId: data['createdByUserId'] as String? ??
          data['payerId'] as String? ??
          unknownCreatorId,
      createdAt: switch (createdAtRaw) {
        String() => DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
      splits: (data['splits'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExpenseSplitModel.fromJson)
          .toList(),
    );
  }

  factory ExpenseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAtRaw = data['createdAt'];
    return ExpenseModel(
      id: data['id'] as String? ?? doc.id,
      householdId: data['householdId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String?,
      payerId: data['payerId'] as String? ?? '',
      createdByUserId: data['createdByUserId'] as String? ??
          data['payerId'] as String? ??
          unknownCreatorId,
      createdAt: switch (createdAtRaw) {
        Timestamp() => createdAtRaw.toDate(),
        String() => DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
      splits: (data['splits'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExpenseSplitModel.fromFirestore)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'householdId': householdId,
      'title': title,
      'amount': amount,
      if (category != null) 'category': category,
      'payerId': payerId,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
      'splits': splits
          .map(
            (split) => ExpenseSplitModel(
              userId: split.userId,
              shareAmount: split.shareAmount,
              isSettled: split.isSettled,
              settledAt: split.settledAt,
            ).toJson(),
          )
          .toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'householdId': householdId,
      'title': title,
      'amount': amount,
      if (category != null) 'category': category,
      'payerId': payerId,
      'createdByUserId': createdByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'splits': splits
          .map(
            (split) => ExpenseSplitModel(
              userId: split.userId,
              shareAmount: split.shareAmount,
              isSettled: split.isSettled,
              settledAt: split.settledAt,
            ).toFirestore(),
          )
          .toList(),
    };
  }
}
