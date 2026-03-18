import 'package:flutter/foundation.dart';

/// Represents a single page in the onboarding carousel.
@immutable
class OnboardingPageEntity {
  const OnboardingPageEntity({
    required this.title,
    required this.description,
    required this.illustrationAsset,
  });

  final String title;
  final String description;
  final String illustrationAsset;
}
