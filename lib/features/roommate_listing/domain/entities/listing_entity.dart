import 'package:flutter/foundation.dart';

/// Domain entity representing a roommate listing.
@immutable
class ListingEntity {
  const ListingEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.rent,
    required this.location,
    required this.imageUrls,
    required this.postedAt,
    this.isAvailable = true,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double rent;
  final String location;
  final List<String> imageUrls;
  final DateTime postedAt;
  final bool isAvailable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
