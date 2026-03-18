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
        title: 'Find Your Perfect Roommate',
        description:
            'Browse verified profiles and connect with compatible roommates near you.',
        illustrationAsset: 'assets/illustrations/onboarding_1.png',
      ),
      OnboardingPageEntity(
        title: 'List Your Space',
        description:
            'Post your room or apartment and reach thousands of potential roommates.',
        illustrationAsset: 'assets/illustrations/onboarding_2.png',
      ),
      OnboardingPageEntity(
        title: 'Chat Safely',
        description:
            'Message roommates directly inside the app before committing to anything.',
        illustrationAsset: 'assets/illustrations/onboarding_3.png',
      ),
    ];
  }
}
