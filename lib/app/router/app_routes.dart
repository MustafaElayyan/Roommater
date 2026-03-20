/// Centralized route name constants used throughout the app.
///
/// Prefer referencing these constants rather than hard-coding strings to avoid
/// typos and make refactoring easier.
abstract final class AppRoutes {
  // --- Auth ---
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';

  // --- Household / Main ---
  static const String home = '/home';
  static const String noHousehold = '/no-household';
  static const String createHousehold = '/household/create';
  static const String joinHousehold = '/household/join';
  static const String manageMembers = '/household/manage-members';

  // --- Tasks ---
  static const String tasks = '/tasks';
  static const String createTask = '/tasks/create';

  // --- Grocery ---
  static const String grocery = '/grocery';

  // --- Events ---
  static const String events = '/events';
  static const String createEvent = '/events/create';
  static const String eventDetail = '/events/:id';

  // --- Expenses ---
  static const String expenses = '/expenses';
  static const String createExpense = '/expenses/create';

  // --- Notifications ---
  static const String notifications = '/notifications';

  // --- Profile ---
  static const String profile = '/profile';

  // --- Settings ---
  static const String settings = '/settings';
}
