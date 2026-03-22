import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

class NoHouseholdScreen extends StatelessWidget {
  const NoHouseholdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.authChoice);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Household')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_work_outlined, size: 60),
                const SizedBox(height: 16),
                const Text("You're not in a household"),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.createHousehold),
                  child: const Text('Create Household'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.joinHousehold),
                  child: const Text('Join Household'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
