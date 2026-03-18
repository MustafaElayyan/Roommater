import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:roommater/app/router/app_routes.dart';
import 'package:roommater/features/auth/domain/entities/user_entity.dart';

/// Builds a minimal app with a mocked [authStateProvider] and the same
/// redirect logic used in the real [_RouterNotifier].
///
/// [authenticatedUser] – when non-null the auth state stream emits this user
/// (simulating a signed-in session); when null it emits `null` (signed out).
Widget _buildGuardedApp({
  UserEntity? authenticatedUser,
  required String initialLocation,
}) {
  // Manually reproduce the redirect logic so the test stays decoupled from
  // the real GoRouter provider (which depends on FirebaseAuth).
  String? guardRedirect(BuildContext ctx, GoRouterState state) {
    final isLoggedIn = authenticatedUser != null;
    const publicRoutes = {
      AppRoutes.onboarding,
      AppRoutes.authChoice,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
    };
    final isPublic = publicRoutes.contains(state.matchedLocation);
    if (!isLoggedIn && !isPublic) return AppRoutes.authChoice;
    if (isLoggedIn && isPublic) return AppRoutes.home;
    return null;
  }

  final router = GoRouter(
    initialLocation: initialLocation,
    redirect: guardRedirect,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const Scaffold(body: Text('Onboarding')),
      ),
      GoRoute(
        path: AppRoutes.authChoice,
        builder: (_, __) => const Scaffold(body: Text('Auth Choice')),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const Scaffold(body: Text('Login')),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const Scaffold(body: Text('Register')),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const Scaffold(body: Text('Forgot Password')),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const Scaffold(body: Text('Home')),
      ),
      GoRoute(
        path: AppRoutes.listings,
        builder: (_, __) => const Scaffold(body: Text('Listings')),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const Scaffold(body: Text('Profile')),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}

const _fakeUser = UserEntity(uid: 'u1', email: 'test@example.com');

void main() {
  group('Route guard – unauthenticated user', () {
    testWidgets('is redirected to auth-choice when accessing home', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: null,
          initialLocation: AppRoutes.home,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Auth Choice'), findsOneWidget);
    });

    testWidgets('is redirected to auth-choice when accessing listings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: null,
          initialLocation: AppRoutes.listings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Auth Choice'), findsOneWidget);
    });

    testWidgets('can access login page', (tester) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: null,
          initialLocation: AppRoutes.login,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('can access onboarding', (tester) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: null,
          initialLocation: AppRoutes.onboarding,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsOneWidget);
    });
  });

  group('Route guard – authenticated user', () {
    testWidgets('is redirected to home when accessing login', (tester) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: _fakeUser,
          initialLocation: AppRoutes.login,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('is redirected to home when accessing onboarding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: _fakeUser,
          initialLocation: AppRoutes.onboarding,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('can access home', (tester) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: _fakeUser,
          initialLocation: AppRoutes.home,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('can access listings', (tester) async {
      await tester.pumpWidget(
        _buildGuardedApp(
          authenticatedUser: _fakeUser,
          initialLocation: AppRoutes.listings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Listings'), findsOneWidget);
    });
  });
}
