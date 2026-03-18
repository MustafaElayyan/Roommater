import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_page_entity.dart';

final _onboardingRepositoryProvider =
    Provider<OnboardingRepositoryImpl>((ref) {
  return const OnboardingRepositoryImpl();
});

/// Exposes the static list of [OnboardingPageEntity] objects.
final onboardingPagesProvider =
    Provider<List<OnboardingPageEntity>>((ref) {
  return ref.watch(_onboardingRepositoryProvider).getPages();
});

/// Tracks the index of the currently displayed onboarding page.
final onboardingPageIndexProvider =
    StateProvider<int>((ref) => 0);
