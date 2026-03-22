import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

/// First-launch onboarding carousel shown before auth choices.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  static const Color _activeDotColor = AppColors.primary;
  static const Color _inactiveDotColor = Color(0x441D7B6F);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuthChoice() {
    context.push(AppRoutes.authChoice);
  }

  Widget _buildIllustration(int index) {
    const icons = [
      Icons.home_outlined,
      Icons.assignment_turned_in_outlined,
      Icons.trending_up_outlined,
    ];
    final icon = icons[index % icons.length];

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight.withValues(alpha: 0.18),
                AppColors.primary.withValues(alpha: 0.12),
              ],
            ),
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.primaryDark.withValues(alpha: 0.32),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 72,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingPageIndexProvider);
    final pages = ref.watch(onboardingPagesProvider);
    final isLastPage = currentIndex == pages.length - 1;
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && currentIndex > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _goToAuthChoice,
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      ref.read(onboardingPageIndexProvider.notifier).state = index;
                    },
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: _buildIllustration(index),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? _activeDotColor
                            : _inactiveDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLastPage
                        ? _goToAuthChoice
                        : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(isLastPage ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
