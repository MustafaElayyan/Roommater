import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/app/router/app_router.dart';
import 'package:roommater/app/router/app_routes.dart';
import 'package:roommater/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

const _onboardingPagesToSwipeToLastPage = 2;

void main() {
  testWidgets('router starts at onboarding screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
  });

  testWidgets('onboarding skip navigates to auth choice screen',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Choose how you want to continue'), findsNothing);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
    expect(find.text('CONTINUE AS GUEST'), findsOneWidget);
  });

  testWidgets('onboarding get started navigates to auth choice screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < _onboardingPagesToSwipeToLastPage; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
    }

    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Choose how you want to continue'), findsNothing);
  });

  testWidgets('system back on auth choice returns to onboarding', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Choose how you want to continue'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Choose how you want to continue'), findsNothing);
  });

  testWidgets('auth choice back arrow returns to onboarding', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Choose how you want to continue'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Choose how you want to continue'), findsNothing);
  });

  testWidgets('auth choice back arrow is in app bar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, equals(AppColors.primaryDark));
    expect(find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.arrow_back)), findsOneWidget);
  });

  testWidgets('system back on onboarding pages moves to previous page', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Coordinate Responsibilities'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Organize Shared Living Together'), findsOneWidget);
  });

  testWidgets('guest flow from auth choice goes to no-household', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE AS GUEST'));
    await tester.pumpAndSettle();

    expect(find.text("You're not in a household"), findsOneWidget);
  });

  testWidgets(
    'auth choice stays usable on small screens without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: _RouterHarness(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      final continueAsGuest = find.text('CONTINUE AS GUEST');
      expect(continueAsGuest, findsOneWidget);

      await tester.ensureVisible(continueAsGuest);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(continueAsGuest);
      await tester.pumpAndSettle();

      expect(find.text("You're not in a household"), findsOneWidget);
    },
  );

  testWidgets('continue as guest tap target meets Material minimum', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final continueButton = find.widgetWithText(
      ElevatedButton,
      'CONTINUE AS GUEST',
    );
    expect(continueButton, findsOneWidget);

    final buttonSize = tester.getSize(continueButton);
    expect(buttonSize.height, greaterThanOrEqualTo(48));
    expect(buttonSize.width, greaterThanOrEqualTo(48));
  });

  testWidgets('router supports profile setup to no-household to home flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));
    GoRouter.of(context).go(AppRoutes.profileSetup);
    await tester.pumpAndSettle();
    expect(find.text('Profile Setup'), findsOneWidget);

    await tester.tap(find.text('Complete Setup'));
    await tester.pumpAndSettle();
    expect(find.text('You\'re not in a household'), findsOneWidget);

    await tester.tap(find.text('Create Household'));
    await tester.pumpAndSettle();
    expect(find.text('Name your household'), findsOneWidget);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Household name is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Household Name'),
      'Sunrise Apartment 4B',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}

class _RouterHarness extends ConsumerWidget {
  const _RouterHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(routerConfig: router);
  }
}
