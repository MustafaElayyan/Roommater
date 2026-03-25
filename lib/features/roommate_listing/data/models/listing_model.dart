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

  factory ListingModel.fromJson(Map<String, dynamic> data) {
    return ListingModel(
      id: data['id'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      rent: (data['rent'] as num? ?? 0).toDouble(),
      location: data['location'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      postedAt: DateTime.tryParse(data['postedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
