import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/app/router/app_router.dart';
import 'package:roommater/app/router/app_routes.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('router starts at login screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouterHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
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
    expect(find.text(\"You're not in a household\"), findsOneWidget);

    await tester.tap(find.text('Create Household'));
    await tester.pumpAndSettle();
    expect(find.text('Create Household'), findsOneWidget);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Roommater'), findsOneWidget);
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
