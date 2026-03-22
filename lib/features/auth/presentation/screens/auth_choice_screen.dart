import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/guest_provider.dart';

/// Screen that lets users explicitly choose sign-up, sign-in, or guest mode.
class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  static const Color _darkTeal = AppColors.primaryDark;
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
          foregroundColor: _darkTeal,
          shape: const StadiumBorder(),
          side: const BorderSide(
            color: _darkTeal,
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

  Widget _buildOrDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: Colors.white70, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'OR',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: Colors.white70, thickness: 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: _darkTeal,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxActionsWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.go(AppRoutes.onboarding),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          _logoAsset,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome to Roommater',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your shared living, simplified',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose how you want to continue',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create a new team account or sign in to keep organizing your shared lifestyle together.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildActionButton(
                        label: 'SIGN IN',
                        onPressed: () => context.push(AppRoutes.login),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        label: 'SIGN UP',
                        onPressed: () => context.push(AppRoutes.register),
                      ),
                      _buildOrDivider(),
                      _buildActionButton(
                        label: 'CONTINUE AS GUEST',
                        onPressed: () {
                          ref.read(isGuestProvider.notifier).state = true;
                          context.go(AppRoutes.noHousehold);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
