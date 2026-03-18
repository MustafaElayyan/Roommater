import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:roommater/app/router/app_routes.dart';
import 'package:roommater/features/auth/presentation/screens/auth_choice_screen.dart';
import 'package:roommater/features/onboarding/presentation/screens/onboarding_screen.dart';

Widget _buildRouterApp({
  required String initialLocation,
  required List<GoRoute> routes,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: routes,
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  group('Onboarding to auth choice flow', () {
    testWidgets(
      'Skip from intro navigates to auth choice screen',
      (tester) async {
        await tester.pumpWidget(
          _buildRouterApp(
            initialLocation: AppRoutes.onboarding,
            routes: [
              GoRoute(
                path: AppRoutes.onboarding,
                builder: (_, __) => const OnboardingScreen(),
              ),
              GoRoute(
                path: AppRoutes.authChoice,
                builder: (_, __) => const Scaffold(body: Text('Auth Choice')),
              ),
            ],
          ),
        );

        expect(find.text('Skip'), findsOneWidget);
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        expect(find.text('Auth Choice'), findsOneWidget);
      },
    );

    testWidgets(
      'Get Started on last intro page navigates to auth choice screen',
      (tester) async {
        await tester.pumpWidget(
          _buildRouterApp(
            initialLocation: AppRoutes.onboarding,
            routes: [
              GoRoute(
                path: AppRoutes.onboarding,
                builder: (_, __) => const OnboardingScreen(),
              ),
              GoRoute(
                path: AppRoutes.authChoice,
                builder: (_, __) => const Scaffold(body: Text('Auth Choice')),
              ),
            ],
          ),
        );

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Get Started'), findsOneWidget);
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        expect(find.text('Auth Choice'), findsOneWidget);
      },
    );
  });

  group('Auth choice actions', () {
    testWidgets('contains Sign Up and Sign In and navigates accordingly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildRouterApp(
          initialLocation: AppRoutes.authChoice,
          routes: [
            GoRoute(
              path: AppRoutes.authChoice,
              builder: (_, __) => const AuthChoiceScreen(),
            ),
            GoRoute(
              path: AppRoutes.register,
              builder: (_, __) => const Scaffold(body: Text('Register Page')),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (_, __) => const Scaffold(body: Text('Login Page')),
            ),
          ],
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Register Page'), findsOneWidget);

      await tester.pumpWidget(
        _buildRouterApp(
          initialLocation: AppRoutes.authChoice,
          routes: [
            GoRoute(
              path: AppRoutes.authChoice,
              builder: (_, __) => const AuthChoiceScreen(),
            ),
            GoRoute(
              path: AppRoutes.register,
              builder: (_, __) => const Scaffold(body: Text('Register Page')),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (_, __) => const Scaffold(body: Text('Login Page')),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
