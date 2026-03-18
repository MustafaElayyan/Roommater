import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/listing_controller.dart';
import '../widgets/listing_card.dart';

/// Screen displaying the paginated list of available roommate listings.
class ListingScreen extends ConsumerWidget {
  const ListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Listings')),
      body: listingsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(child: Text('No listings found.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(listingControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  ListingCard(listing: listings[index]),
            ),
          );
        },
      ),
    );
  }
}
