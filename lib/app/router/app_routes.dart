/// Centralized route name constants used throughout the app.
///
/// Prefer referencing these constants rather than hard-coding strings to avoid
/// typos and make refactoring easier.
abstract final class AppRoutes {
  // --- Onboarding ---
  static const String onboarding = '/onboarding';

  // --- Auth ---
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
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
  static const String editTask = '/tasks/edit';

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
  static const String profileDetailsBase = '/profile-details';
  static const String profileDetails = '$profileDetailsBase/:userId';
  static String profileDetailsFor(String userId) => '$profileDetailsBase/$userId';

  // --- Settings ---
  static const String settings = '/settings';
  static const String updatePassword = '/settings/update-password';
  static const String householdSettings = '/settings/household';
}
