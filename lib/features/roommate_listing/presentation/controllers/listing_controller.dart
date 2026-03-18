import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../data/datasources/listing_remote_datasource.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../domain/usecases/get_listings_usecase.dart';

// --- Dependency graph ---

final _listingDataSourceProvider =
    Provider<ListingRemoteDataSource>((ref) {
  return ListingRemoteDataSource(ref.watch(firestoreProvider));
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepositoryImpl(ref.watch(_listingDataSourceProvider));
});

final _getListingsUseCaseProvider = Provider<GetListingsUseCase>((ref) {
  return GetListingsUseCase(ref.watch(listingRepositoryProvider));
});

// --- State ---

/// Async list of available listings for the listing feed screen.
final listingsProvider =
    FutureProvider<List<ListingEntity>>((ref) async {
  return ref.watch(_getListingsUseCaseProvider)();
});

// --- Controller ---

class ListingController extends AsyncNotifier<List<ListingEntity>> {
  @override
  Future<List<ListingEntity>> build() async {
    return ref.watch(_getListingsUseCaseProvider)();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_getListingsUseCaseProvider)(),
    );
  }
}

final listingControllerProvider =
    AsyncNotifierProvider<ListingController, List<ListingEntity>>(
  ListingController.new,
);
