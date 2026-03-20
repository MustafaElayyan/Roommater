import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the current page index of the onboarding carousel.
final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);
