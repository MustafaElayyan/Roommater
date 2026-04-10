import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen that lets users explicitly choose sign-up or sign-in.
class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  static const Color _primaryDark = AppColors.primaryDark;
  static const String _logoAsset = 'Logo.png';
  static const double _maxActionsWidth = 420;

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _primaryDark,
          shape: const StadiumBorder(),
          side: const BorderSide(
            color: _primaryDark,
            width: 2,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) {
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: _primaryDark,
        body: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _maxActionsWidth,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      _logoAsset,
                                      height: 280,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Welcome to Roommater',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your shared living, simplified',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.white70),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                     SizedBox(
                                       width: double.infinity,
                                        child: _buildActionButton(
                                          label: 'SIGN IN',
                                          onPressed: () => context.push(AppRoutes.login),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                     SizedBox(
                                       width: double.infinity,
                                        child: _buildActionButton(
                                          label: 'SIGN UP',
                                          onPressed: () => context.push(AppRoutes.register),
                                        ),
                                      ),
                                   ],
                                 ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.onboarding),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
