import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/listing_model.dart';

/// Handles all listings API calls.
class ListingRemoteDataSource {
  const ListingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ListingModel>> getListings({
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      final response = await _apiClient.getJsonList(
        'listings',
        queryParameters: {
          'limit': limit,
          if (startAfterId != null) 'startAfterId': startAfterId,
        },
      );
      return response
          .whereType<Map<String, dynamic>>()
          .map(ListingModel.fromJson)
          .toList();
    } on AppException catch (e) {
      throw ApiException('Failed to load listings.', e);
    }
  }

  Future<ListingModel> getListingById(String id) async {
    try {
      final response = await _apiClient.getJson('listings/$id');
      return ListingModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to load listing.', e);
    }
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      final response = await _apiClient.postJson(
        'listings',
        body: listing.toJson(),
      );
      return ListingModel.fromJson(response);
    } on AppException catch (e) {
      throw ApiException('Failed to create listing.', e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _apiClient.delete('listings/$id');
    } on AppException catch (e) {
      throw ApiException('Failed to delete listing.', e);
    }
  }
}
