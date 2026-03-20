import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:roommater/app/router/app_routes.dart';
import 'package:roommater/features/auth/presentation/controllers/guest_provider.dart';
import 'package:roommater/features/auth/presentation/screens/auth_choice_screen.dart';
import 'package:roommater/features/auth/presentation/screens/login_screen.dart';
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

String _currentOnboardingAsset(WidgetTester tester) {
  final image = tester.widget<Image>(find.byType(Image).first);
  return (image.image as AssetImage).assetName;
}

// 140 px ~= 32(top gap) + ~56*2(buttons) + 12(gap) + 24(bottom gap),
// allowing expected header/footer space while ensuring actions stay centered.
const double _maxButtonsCenterTolerance = 140;

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
        expect(find.widgetWithText(ElevatedButton, 'Skip'), findsOneWidget);
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

    testWidgets(
      'system back from auth choice returns to onboarding when opened from skip',
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
                builder: (_, __) => const AuthChoiceScreen(),
              ),
            ],
          ),
        );

        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        expect(find.text('Choose how you want to continue'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Next'), findsOneWidget);
      },
    );

    testWidgets('intro slides show distinct illustrations', (tester) async {
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

      expect(
        _currentOnboardingAsset(tester),
        'assets/illustrations/onboarding_1.png',
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(
        _currentOnboardingAsset(tester),
        'assets/illustrations/onboarding_2.png',
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(
        _currentOnboardingAsset(tester),
        'assets/illustrations/onboarding_3.png',
      );
    });

    testWidgets(
      'pagination dots remain visible and active dot is distinct',
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

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        final backgroundColor =
            scaffold.backgroundColor ??
            Theme.of(
              tester.element(find.byType(OnboardingScreen)),
            ).scaffoldBackgroundColor;

        final activeDot = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('onboarding-dot-0')),
        );
        final inactiveDot = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('onboarding-dot-1')),
        );

        final activeDecoration = activeDot.decoration! as BoxDecoration;
        final inactiveDecoration = inactiveDot.decoration! as BoxDecoration;

        expect(activeDecoration.color, isNotNull);
        expect(inactiveDecoration.color, isNotNull);
        expect(
          activeDecoration.color,
          isNot(equals(inactiveDecoration.color)),
        );
        expect(activeDecoration.color, isNot(equals(backgroundColor)));
        expect(inactiveDecoration.color, isNot(equals(backgroundColor)));
      },
    );

    testWidgets('system back moves onboarding slide 3 -> 2 -> 1', (
      tester,
    ) async {
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
      expect(
        _currentOnboardingAsset(tester),
        'assets/illustrations/onboarding_3.png',
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        _currentOnboardingAsset(tester),
        'assets/illustrations/onboarding_2.png',
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        _currentOnboardingAsset(tester),
        'assets/illustrations/onboarding_1.png',
      );
    });
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
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const Scaffold(body: Text('Home Page')),
            ),
          ],
        ),
      );

      expect(find.byType(ElevatedButton), findsNWidgets(3));
      expect(find.widgetWithText(ElevatedButton, 'SIGN IN'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'SIGN UP'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'CONTINUE AS GUEST'),
        findsOneWidget,
      );
      expect(find.text('OR'), findsOneWidget);
      final signInCenter =
          tester.getCenter(find.widgetWithText(ElevatedButton, 'SIGN IN'));
      final signUpCenter =
          tester.getCenter(find.widgetWithText(ElevatedButton, 'SIGN UP'));
      final viewportCenterY = tester.binding.renderView.size.height / 2;
      final buttonsCenterY = (signInCenter.dy + signUpCenter.dy) / 2;
      expect(
        (buttonsCenterY - viewportCenterY).abs(),
        lessThan(_maxButtonsCenterTolerance),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFC19A6B));

      await tester.tap(find.text('SIGN UP'));
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
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const Scaffold(body: Text('Home Page')),
            ),
          ],
        ),
      );

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('continue as guest sets guest mode and navigates to home', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: AppRoutes.authChoice,
        routes: [
          GoRoute(
            path: AppRoutes.authChoice,
            builder: (_, __) => const AuthChoiceScreen(),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (_, __) => const Scaffold(body: Text('Login Page')),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (_, __) => const Scaffold(body: Text('Register Page')),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('Home Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(container.read(isGuestProvider), isFalse);

      await tester.tap(find.text('CONTINUE AS GUEST'));
      await tester.pumpAndSettle();

      expect(container.read(isGuestProvider), isTrue);
      expect(find.text('Home Page'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Choose how you want to continue'), findsNothing);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets(
      'system back from sign in returns to auth choice',
      (tester) async {
        await tester.pumpWidget(
          _buildRouterApp(
            initialLocation: AppRoutes.authChoice,
            routes: [
              GoRoute(
                path: AppRoutes.authChoice,
                builder: (_, __) => const AuthChoiceScreen(),
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (_, __) => const Scaffold(body: Text('Login Page')),
              ),
            ],
          ),
        );

        await tester.tap(find.text('SIGN IN'));
        await tester.pumpAndSettle();
        expect(find.text('Login Page'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Choose how you want to continue'), findsOneWidget);
      },
    );

    testWidgets('sign in shows register helper and opens sign up', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildRouterApp(
          initialLocation: AppRoutes.login,
          routes: [
            GoRoute(
              path: AppRoutes.login,
              builder: (_, __) => const LoginScreen(),
            ),
            GoRoute(
              path: AppRoutes.register,
              builder: (_, __) => const Scaffold(body: Text('Register Page')),
            ),
          ],
        ),
      );

      expect(find.text('Forgot Password?'), findsOneWidget);
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(
        find.text('Password reset is not available yet.'),
        findsOneWidget,
      );

      expect(find.text("Don't have account? Register"), findsOneWidget);

      await tester.tap(find.text("Don't have account? Register"));
      await tester.pumpAndSettle();
      expect(find.text('Register Page'), findsOneWidget);
    });
  });
}
