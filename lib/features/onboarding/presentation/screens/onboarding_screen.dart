import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

/// Multi-page onboarding carousel shown on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  static const Color _activeDotColor = Color(0xFF2D2115);
  static const Color _inactiveDotColor = Color(0xFFEFE5D6);
  static const Color _activeDotBorderColor = Colors.white;
  static const Color _inactiveDotBorderColor = Colors.black87;
  static const List<IconData> _slideIcons = [
    Icons.groups_2_outlined,
    Icons.checklist_rtl_outlined,
    Icons.calendar_month_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(onboardingPageIndexProvider.notifier).state = index;
  }

  void _nextOrFinish(int currentIndex, int totalPages) {
    if (currentIndex < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.authChoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingPagesProvider);
    final currentIndex = ref.watch(onboardingPageIndexProvider);

    return Scaffold(
      body: PopScope(
        canPop: currentIndex == 0,
        onPopInvoked: (didPop) {
          if (didPop || currentIndex == 0) return;
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              height: 96,
                              width: 96,
                              child: Image.asset(
                                page.illustrationAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  _slideIcons[index],
                                  size: 96,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (i) => AnimatedContainer(
                          key: ValueKey('onboarding-dot-$i'),
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == currentIndex ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                i == currentIndex
                                    ? _activeDotColor
                                    : _inactiveDotColor,
                            border: Border.all(
                              color:
                                  i == currentIndex
                                      ? _activeDotBorderColor
                                      : _inactiveDotBorderColor,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: currentIndex < pages.length - 1
                          ? 'Next'
                          : 'Get Started',
                      onPressed: () =>
                          _nextOrFinish(currentIndex, pages.length),
                    ),
                    const SizedBox(height: 8),
                    if (currentIndex < pages.length - 1)
                      TextButton(
                        onPressed: () => context.go(AppRoutes.authChoice),
                        child: const Text('Skip'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
