/// Centralized route name constants used throughout the app.
///
/// Prefer referencing these constants rather than hard-coding strings to avoid
/// typos and make refactoring easier.
abstract final class AppRoutes {
  // --- Auth ---
  static const String login = '/login';
  static const String register = '/register';

  // --- Onboarding ---
  static const String onboarding = '/onboarding';

  // --- Main shell ---
  static const String home = '/home';

  // --- Roommate Listings ---
  static const String listings = '/listings';
  static const String listingDetail = '/listings/:id';

  // --- Chat ---
  static const String chatList = '/chats';
  static const String chatRoom = '/chats/:id';

  // --- Profile ---
  static const String profile = '/profile';

  // --- Settings ---
  static const String settings = '/settings';
}
