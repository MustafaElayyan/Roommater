import '../../../../core/errors/app_exception.dart';
import '../../../../core/local/local_store.dart';
import '../models/listing_model.dart';

/// Handles all local data calls related to listings.
class ListingRemoteDataSource {
  const ListingRemoteDataSource();

  Future<List<ListingModel>> getListings({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      final items = LocalStore.listingsById.values
          .where((listing) => listing.isAvailable)
          .toList()
        ..sort((a, b) => b.postedAt.compareTo(a.postedAt));

      if (startAfterId != null) {
        final startIndex = items.indexWhere((listing) => listing.id == startAfterId);
        if (startIndex >= 0 && startIndex + 1 < items.length) {
          return items.skip(startIndex + 1).take(limit).toList();
        }
        return const [];
      }
      return items.take(limit).toList();
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to load listings.', e);
    }
  }

  Future<ListingModel> getListingById(String id) async {
    try {
      final listing = LocalStore.listingsById[id];
      if (listing == null) throw const DataStoreException('Listing not found.');
      return listing;
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to load listing.', e);
    }
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      final created = ListingModel(
        id: listing.id.isNotEmpty ? listing.id : LocalStore.nextId('listing'),
        ownerId: listing.ownerId,
        title: listing.title,
        description: listing.description,
        rent: listing.rent,
        location: listing.location,
        imageUrls: listing.imageUrls,
        postedAt: listing.postedAt,
        isAvailable: listing.isAvailable,
      );
      LocalStore.listingsById[created.id] = created;
      return created;
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to create listing.', e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      LocalStore.listingsById.remove(id);
    } on DataStoreException {
      rethrow;
    } catch (e) {
      throw DataStoreException('Failed to delete listing.', e);
    }
  }
}
