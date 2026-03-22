import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Icon(Icons.person, size: 40),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Mustafa Elayyan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          Center(child: Text('UI preview profile data')),
        ],
      ),
    );
  }
}
