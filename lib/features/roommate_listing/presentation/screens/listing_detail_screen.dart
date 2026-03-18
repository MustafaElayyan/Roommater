import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/datasources/listing_remote_datasource.dart';
import '../../domain/entities/listing_entity.dart';

final _singleListingProvider =
    FutureProvider.family<ListingEntity, String>((ref, id) async {
  final ds = ListingRemoteDataSource(ref.watch(firestoreProvider));
  return ds.getListingById(id);
});

/// Full-detail view for a single roommate listing.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(_singleListingProvider(listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: listingAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listing) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                listing.location,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '\$${listing.rent.toStringAsFixed(0)}/mo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                listing.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
