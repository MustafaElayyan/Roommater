import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/auth_choice_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/roommate_listing/presentation/screens/listing_detail_screen.dart';
import '../../features/roommate_listing/presentation/screens/listing_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

// ---------------------------------------------------------------------------
// Router notifier
// ---------------------------------------------------------------------------

/// Routes that do not require authentication.
const _publicRoutes = {
  AppRoutes.onboarding,
  AppRoutes.authChoice,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

/// A [ChangeNotifier] that bridges Riverpod auth state to GoRouter so that
/// the router re-evaluates its redirect logic whenever the auth state changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  /// Called by GoRouter on every navigation event (and whenever this notifier
  /// fires).  Returns a redirect path or `null` to allow the navigation.
  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);

    // While the auth stream hasn't emitted yet, allow the current location.
    if (authAsync.isLoading) return null;

    final isLoggedIn = authAsync.valueOrNull != null;
    final loc = state.matchedLocation;
    final isPublic = _publicRoutes.contains(loc);

    if (!isLoggedIn && !isPublic) {
      // Unauthenticated user attempting to reach a protected route.
      return AppRoutes.authChoice;
    }

    if (isLoggedIn && isPublic) {
      // Authenticated user on a public-only screen — send them home.
      return AppRoutes.home;
    }

    return null;
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final _routerNotifierProvider =
    ChangeNotifierProvider<_RouterNotifier>((ref) => _RouterNotifier(ref));

/// Riverpod provider that exposes the app-wide [GoRouter] instance.
///
/// The router is created once and reused for the lifetime of the app.
/// Authentication redirects are handled via [_RouterNotifier].
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.authChoice,
        builder: (BuildContext context, GoRouterState state) =>
            const AuthChoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.listings,
        builder: (BuildContext context, GoRouterState state) =>
            const ListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.listingDetail,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return ListingDetailScreen(listingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.chatList,
        builder: (BuildContext context, GoRouterState state) =>
            const ChatListScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatRoomScreen(chatId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
});
