import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_choice_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/expenses/presentation/screens/create_expense_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/grocery/presentation/screens/grocery_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/household/presentation/screens/create_household_screen.dart';
import '../../features/household/presentation/screens/join_household_screen.dart';
import '../../features/household/presentation/screens/manage_members_screen.dart';
import '../../features/household/presentation/screens/no_household_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tasks/presentation/screens/create_task_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.authChoice,
        builder: (context, state) => const AuthChoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.noHousehold,
        builder: (context, state) => const NoHouseholdScreen(),
      ),
      GoRoute(
        path: AppRoutes.createHousehold,
        builder: (context, state) => const CreateHouseholdScreen(),
      ),
      GoRoute(
        path: AppRoutes.joinHousehold,
        builder: (context, state) => const JoinHouseholdScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageMembers,
        builder: (context, state) => const ManageMembersScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.createTask,
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: AppRoutes.grocery,
        builder: (context, state) => const GroceryScreen(),
      ),
      GoRoute(
        path: AppRoutes.events,
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createEvent,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: AppRoutes.createExpense,
        builder: (context, state) => const CreateExpenseScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
