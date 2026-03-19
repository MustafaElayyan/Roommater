import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen that lets users explicitly choose sign-up or sign-in.
class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  static const Color _camelBackground = Color(0xFFC19A6B);
  static const double _maxActionsWidth = 420;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Scaffold(
      backgroundColor: _camelBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Choose how you want to continue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create a new team account or sign in to keep organizing your shared lifestyle together.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/illustrations/onboarding_1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxActionsWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          label: 'SIGN IN',
                          onPressed: () => context.push(AppRoutes.login),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'SIGN UP',
                          onPressed: () => context.push(AppRoutes.register),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
