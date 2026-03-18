import '../../domain/entities/onboarding_page_entity.dart';

/// Provides the static onboarding page data.
///
/// In a future iteration this could read from remote config to allow A/B
/// testing of onboarding copy without an app release.
class OnboardingRepositoryImpl {
  const OnboardingRepositoryImpl();

  List<OnboardingPageEntity> getPages() {
    return const [
      OnboardingPageEntity(
        title: 'Organize Shared Living Together',
        description:
            'Roommater helps teams and housemates coordinate daily lifestyle routines in one place.',
        illustrationAsset: 'assets/illustrations/onboarding_1.png',
      ),
      OnboardingPageEntity(
        title: 'Coordinate Responsibilities',
        description:
            'Plan chores, responsibilities, and personal commitments so everyone stays aligned.',
        illustrationAsset: 'assets/illustrations/onboarding_2.png',
      ),
      OnboardingPageEntity(
        title: 'Keep Plans Moving',
        description:
            'Track shared plans and day-to-day progress to keep your team running smoothly.',
        illustrationAsset: 'assets/illustrations/onboarding_3.png',
      ),
    ];
  }
}
