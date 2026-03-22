import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    child: Icon(Icons.person, size: 40),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const TextField(decoration: InputDecoration(labelText: 'Display Name')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.noHousehold),
              child: const Text('Complete Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
