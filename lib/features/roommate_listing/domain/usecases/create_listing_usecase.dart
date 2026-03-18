import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

/// Use case: publish a new roommate listing.
class CreateListingUseCase {
  const CreateListingUseCase(this._repository);

  final ListingRepository _repository;

  Future<ListingEntity> call(ListingEntity listing) {
    return _repository.createListing(listing);
  }
}
