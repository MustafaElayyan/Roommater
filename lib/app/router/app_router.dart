import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/guest_provider.dart';
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
  final routerNotifier = _RouterNotifier(ref);
  ref.onDispose(routerNotifier.dispose);

  const publicRoutes = <String>{
    AppRoutes.onboarding,
    AppRoutes.authChoice,
    AppRoutes.login,
    AppRoutes.register,
  };
  const authOnlyRoutes = <String>{
    AppRoutes.authChoice,
    AppRoutes.login,
    AppRoutes.register,
  };
  const guestAccessibleRoutes = <String>{
    AppRoutes.noHousehold,
    AppRoutes.createHousehold,
    AppRoutes.joinHousehold,
    AppRoutes.home,
  };

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;
      if (authState is AsyncError<UserEntity?>) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final isGuest = ref.read(isGuestProvider);
      final location = state.matchedLocation;
      final isPublicRoute = publicRoutes.contains(location);
      final isAuthRoute = authOnlyRoutes.contains(location);
      final isGuestAccessibleRoute = guestAccessibleRoutes.contains(location);

      if (!isLoggedIn && !isPublicRoute) {
        if (isGuest && isGuestAccessibleRoute) {
          return null;
        }
        return AppRoutes.authChoice;
      }

      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
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
      ShellRoute(
        builder: (context, state, child) => _MainShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.tasks,
            builder: (context, state) => const TasksScreen(),
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
            path: AppRoutes.expenses,
            builder: (context, state) => const ExpensesScreen(),
          ),
        ],
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
        path: AppRoutes.createTask,
        builder: (context, state) => const CreateTaskScreen(),
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

/// Bridges Riverpod auth state updates to GoRouter via [refreshListenable].
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _subscription = _ref.listenManual<AsyncValue<UserEntity?>>(
      authStateProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserEntity?>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = <String>[
    AppRoutes.home,
    AppRoutes.tasks,
    AppRoutes.grocery,
    AppRoutes.events,
    AppRoutes.expenses,
  ];

  int _selectedIndex() {
    if (location.startsWith(AppRoutes.tasks)) return 1;
    if (location.startsWith(AppRoutes.grocery)) return 2;
    if (location.startsWith(AppRoutes.events)) return 3;
    if (location.startsWith(AppRoutes.expenses)) return 4;
    return 0;
  }

  String _title() {
    switch (_selectedIndex()) {
      case 1:
        return 'Tasks';
      case 2:
        return 'Grocery List';
      case 3:
        return 'Events';
      case 4:
        return 'Expenses';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex();
    final themeMode = ref.watch(themeModeProvider);

    void goToShellRoute(String route) {
      Navigator.of(context).pop();
      context.go(route);
    }

    void pushToTopLevelRoute(String route) {
      Navigator.of(context).pop();
      context.go(route);
    }

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop && selectedIndex != 0) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title()),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                switch (themeMode) {
                  ThemeMode.system => Icons.brightness_auto,
                  ThemeMode.dark => Icons.dark_mode,
                  ThemeMode.light => Icons.light_mode,
                },
              ),
              onPressed: () =>
                  ref.read(themeModeProvider.notifier).toggleDarkMode(),
            ),
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Text(
                    'Menu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () => pushToTopLevelRoute(AppRoutes.profile),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () => pushToTopLevelRoute(AppRoutes.settings),
                ),
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: const Text('Manage Members'),
                  onTap: () => pushToTopLevelRoute(AppRoutes.manageMembers),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  onTap: () => pushToTopLevelRoute(AppRoutes.notifications),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    try {
                      ref.read(isGuestProvider.notifier).state = false;
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) context.go(AppRoutes.authChoice);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to sign out')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) => context.go(_tabs[i]),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Grocery',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Expenses',
            ),
          ],
        ),
      ),
    );
  }
}
