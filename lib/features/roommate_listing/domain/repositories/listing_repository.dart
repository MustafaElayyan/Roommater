import '../entities/listing_entity.dart';

/// Contract for listing CRUD operations.
abstract interface class ListingRepository {
  /// Returns a paginated list of available listings.
  Future<List<ListingEntity>> getListings({int limit = 20, String? startAfterId});

  /// Returns a single listing by [id].
  Future<ListingEntity> getListingById(String id);

  /// Creates a new listing and returns the persisted entity.
  Future<ListingEntity> createListing(ListingEntity listing);

  /// Deletes the listing with [id].
  Future<void> deleteListing(String id);
}
