import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/grocery_item_entity.dart';

class GroceryItemModel extends GroceryItemEntity {
  const GroceryItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.addedBy,
    required super.isPurchased,
    super.purchasedBy,
    super.purchasedAt,
    required super.householdId,
    required super.createdAt,
  });

  factory GroceryItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final purchasedAtRaw = data['purchasedAt'];
    final createdAtRaw = data['createdAt'];
    return GroceryItemModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 1,
      addedBy: data['addedBy'] as String? ?? '',
      isPurchased: data['isPurchased'] as bool? ?? false,
      purchasedBy: data['purchasedBy'] as String?,
      purchasedAt: switch (purchasedAtRaw) {
        Timestamp() => purchasedAtRaw.toDate(),
        String() => DateTime.tryParse(purchasedAtRaw),
        _ => null,
      },
      householdId: data['householdId'] as String? ?? '',
      createdAt: switch (createdAtRaw) {
        Timestamp() => createdAtRaw.toDate(),
        String() => DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
        _ => DateTime.now(),
      },
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'addedBy': addedBy,
      'isPurchased': isPurchased,
      if (purchasedBy != null) 'purchasedBy': purchasedBy,
      if (purchasedAt != null) 'purchasedAt': Timestamp.fromDate(purchasedAt!),
      'householdId': householdId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
