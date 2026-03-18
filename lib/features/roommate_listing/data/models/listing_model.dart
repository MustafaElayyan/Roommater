import '../../domain/entities/listing_entity.dart';

/// Data-layer model for a Firestore listing document.
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
      String docId, Map<String, dynamic> data) {
    return ListingModel(
      id: docId,
      ownerId: data['ownerId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      rent: (data['rent'] as num).toDouble(),
      location: data['location'] as String,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      postedAt: DateTime.parse(data['postedAt'] as String),
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'rent': rent,
      'location': location,
      'imageUrls': imageUrls,
      'postedAt': postedAt.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}
