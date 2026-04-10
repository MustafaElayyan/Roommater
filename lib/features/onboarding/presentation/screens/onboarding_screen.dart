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
  static const double _skipButtonReplacementHeight = 40;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuthChoice() {
    context.go(AppRoutes.login);
  }

  Widget _buildIllustration(int index) {
    const icons = [
      Icons.home_outlined,
      Icons.assignment_turned_in_outlined,
      Icons.trending_up_outlined,
    ];
    final icon = icons[index % icons.length];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientTopColor =
        AppColors.primaryLight.withValues(alpha: isDarkMode ? 0.35 : 0.18);
    final gradientBottomColor =
        AppColors.primary.withValues(alpha: isDarkMode ? 0.25 : 0.12);
    final cardColor = AppColors.primary.withValues(alpha: isDarkMode ? 0.28 : 0.14);
    final borderColor =
        AppColors.primaryDark.withValues(alpha: isDarkMode ? 0.5 : 0.32);
    final iconColor = isDarkMode ? AppColors.primaryLight : AppColors.primaryDark;

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
                gradientTopColor,
                gradientBottomColor,
              ],
            ),
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 72,
            color: iconColor,
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
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = colorScheme.onSurface;
    final descriptionColor = colorScheme.onSurface.withValues(alpha: 0.7);
    return PopScope(
      canPop: currentIndex == 0,
      // Change this line:
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
                if (isLastPage)
                  const SizedBox(height: _skipButtonReplacementHeight)
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _goToAuthChoice,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      ref.read(onboardingPageIndexProvider.notifier).state =
                          index;
                    },
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: _buildIllustration(index),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            page.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            page.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: descriptionColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
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
