import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

/// Use case: fetch a paginated list of available listings.
class GetListingsUseCase {
  const GetListingsUseCase(this._repository);

  final ListingRepository _repository;

  Future<List<ListingEntity>> call({
    int limit = 20,
    String? startAfterId,
  }) {
    return _repository.getListings(limit: limit, startAfterId: startAfterId);
  }
}
