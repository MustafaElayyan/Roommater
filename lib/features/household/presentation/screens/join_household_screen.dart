import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class JoinHouseholdScreen extends StatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  State<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends State<JoinHouseholdScreen> {
  final _controller = TextEditingController();
  static const _households = <String>[
    'Sunrise Apartment 4B',
    'Maple Residency',
    'Downtown Loft',
    'Green View House',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          context.go(AppRoutes.noHousehold);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRoutes.noHousehold),
                  ),
                ),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.group_add_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Join a household',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Search for an existing household to send a join request.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Autocomplete<String>(
                  optionsBuilder: (value) {
                    if (value.text.trim().isEmpty) return _households;
                    return _households.where(
                      (h) => h.toLowerCase().contains(value.text.toLowerCase()),
                    );
                  },
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Household name',
                        hintText: 'Search household...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => _controller.text = value,
                    );
                  },
                  onSelected: (selection) => _controller.text = selection,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Request sent successfully.')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Send Request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
