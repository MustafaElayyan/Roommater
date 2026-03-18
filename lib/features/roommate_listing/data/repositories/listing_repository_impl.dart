import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_datasource.dart';
import '../models/listing_model.dart';

/// Local-data implementation of [ListingRepository].
class ListingRepositoryImpl implements ListingRepository {
  const ListingRepositoryImpl(this._dataSource);

  final ListingRemoteDataSource _dataSource;

  @override
  Future<List<ListingEntity>> getListings({
    int limit = 20,
    String? startAfterId,
  }) {
    return _dataSource.getListings(limit: limit, startAfterId: startAfterId);
  }

  @override
  Future<ListingEntity> getListingById(String id) {
    return _dataSource.getListingById(id);
  }

  @override
  Future<ListingEntity> createListing(ListingEntity listing) {
    return _dataSource.createListing(
      ListingModel(
        id: listing.id,
        ownerId: listing.ownerId,
        title: listing.title,
        description: listing.description,
        rent: listing.rent,
        location: listing.location,
        imageUrls: listing.imageUrls,
        postedAt: listing.postedAt,
        isAvailable: listing.isAvailable,
      ),
    );
  }

  @override
  Future<void> deleteListing(String id) {
    return _dataSource.deleteListing(id);
  }
}
