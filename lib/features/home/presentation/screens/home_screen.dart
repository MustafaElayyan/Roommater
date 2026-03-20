import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(homeTabIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roommater'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text('Household Menu'),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () => context.go(AppRoutes.profile),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () => context.go(AppRoutes.settings),
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('Manage Members'),
                onTap: () => context.go(AppRoutes.manageMembers),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Leave Household'),
                onTap: () async {
                  final shouldLeave = await showDialog<bool>(
                    context: context,
                    builder: (_) => const ConfirmationDialog(
                      title: 'Leave Household',
                      message: 'Are you sure you want to leave this household?',
                      confirmLabel: 'Leave',
                    ),
                  );
                  if (context.mounted && (shouldLeave ?? false)) {
                    context.go(AppRoutes.noHousehold);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: tabIndex,
        children: const [
          _DashboardTab(),
          _RouteTab(title: 'Tasks', route: AppRoutes.tasks),
          _RouteTab(title: 'Grocery', route: AppRoutes.grocery),
          _RouteTab(title: 'Events', route: AppRoutes.events),
          _RouteTab(title: 'Expenses', route: AppRoutes.expenses),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (i) =>
            ref.read(homeTabIndexProvider.notifier).state = i,
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
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskChecks = ref.watch(homeTaskChecksProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sunrise Apartment 4B',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    CircleAvatar(child: Text('A')),
                    SizedBox(width: 8),
                    CircleAvatar(child: Text('L')),
                    SizedBox(width: 8),
                    CircleAvatar(child: Text('M')),
                    SizedBox(width: 8),
                    CircleAvatar(child: Text('S')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("Today's Tasks", style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: Column(
            children: [
              CheckboxListTile(
                value: taskChecks[0],
                onChanged: (v) => _toggleTask(ref, 0, v),
                title: const Text('Wash dishes'),
              ),
              CheckboxListTile(
                value: taskChecks[1],
                onChanged: (v) => _toggleTask(ref, 1, v),
                title: const Text('Take out trash'),
              ),
              CheckboxListTile(
                value: taskChecks[2],
                onChanged: (v) => _toggleTask(ref, 2, v),
                title: const Text('Clean living room'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Upcoming Events', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.event),
                title: Text('House Meeting'),
                subtitle: Text('Tomorrow • 7:00 PM'),
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Movie Night'),
                subtitle: Text('Friday • 9:00 PM'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('Ahmad completed Kitchen cleaning task'),
              ),
              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('New expense added: Grocery run'),
              ),
              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('Lana joined the house meeting event'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleTask(WidgetRef ref, int index, bool? value) {
    final next = [...ref.read(homeTaskChecksProvider)];
    next[index] = value ?? false;
    ref.read(homeTaskChecksProvider.notifier).state = next;
  }
}

class _RouteTab extends StatelessWidget {
  const _RouteTab({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => context.go(route),
        icon: const Icon(Icons.open_in_new),
        label: Text('Open $title'),
      ),
    );
  }
}
