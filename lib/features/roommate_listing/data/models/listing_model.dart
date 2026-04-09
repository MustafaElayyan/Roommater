import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing_entity.dart';

/// Data-layer model for a listing payload.
class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.rent,
    required super.location,
    required super.imageUrls,
    required super.postedAt,
    super.isAvailable,
  });

  factory ListingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final postedAtRaw = data['postedAt'];
    final postedAt = switch (postedAtRaw) {
      Timestamp() => postedAtRaw.toDate(),
      String() =>
        DateTime.tryParse(postedAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0),
      _ => DateTime.fromMillisecondsSinceEpoch(0),
    };

    return ListingModel(
      id: data['id'] as String? ?? doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      rent: (data['rent'] as num? ?? 0).toDouble(),
      location: data['location'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      postedAt: postedAt,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'rent': rent,
      'location': location,
      'imageUrls': imageUrls,
      'postedAt': Timestamp.fromDate(postedAt),
      'isAvailable': isAvailable,
    };
  }
}
