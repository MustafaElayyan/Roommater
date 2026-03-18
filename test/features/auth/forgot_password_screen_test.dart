import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:roommater/app/router/app_routes.dart';
import 'package:roommater/features/auth/presentation/screens/forgot_password_screen.dart';

Widget _buildApp({List<GoRoute> extraRoutes = const []}) {
  final router = GoRouter(
    initialLocation: AppRoutes.forgotPassword,
    routes: [
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Text('Sign In')),
      ),
      ...extraRoutes,
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('renders the email field and submit button', (tester) async {
      await tester.pumpWidget(_buildApp());

      expect(find.widgetWithText(AppBar, 'Reset Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Send Reset Link'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Reset Link'));
      await tester.pump();

      expect(find.text('Enter your email.'), findsOneWidget);
    });

    testWidgets('shows validation error for malformed email', (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Reset Link'));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('accepts a valid email without showing validation error',
        (tester) async {
      await tester.pumpWidget(_buildApp());

      await tester.enterText(find.byType(TextFormField), 'user@example.com');
      await tester.pump();

      // Tap send – validation passes (no error message visible).
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Reset Link'));
      await tester.pump();

      expect(find.text('Enter your email.'), findsNothing);
      expect(find.text('Enter a valid email address.'), findsNothing);
    });
  });
}
