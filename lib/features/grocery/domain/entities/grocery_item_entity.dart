import 'package:flutter/foundation.dart';

@immutable
class GroceryItemEntity {
  const GroceryItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    required this.addedBy,
    required this.isPurchased,
    this.purchasedBy,
    this.purchasedAt,
    required this.householdId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int quantity;
  final String addedBy;
  final bool isPurchased;
  final String? purchasedBy;
  final DateTime? purchasedAt;
  final String householdId;
  final DateTime createdAt;
}
