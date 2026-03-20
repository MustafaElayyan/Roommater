import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_page_entity.dart';

/// Tracks the current page index of the onboarding carousel.
final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);

final onboardingRepositoryProvider = Provider<OnboardingRepositoryImpl>((ref) {
  return const OnboardingRepositoryImpl();
});

/// Exposes onboarding pages from the data layer for presentation widgets.
final onboardingPagesProvider = Provider<List<OnboardingPageEntity>>((ref) {
  return ref.watch(onboardingRepositoryProvider).getPages();
});
