import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/member_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/household_controller.dart';

class ManageMembersScreen extends ConsumerWidget {
  const ManageMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(currentHouseholdProvider);

    if (household == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Members'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: const Center(child: Text('No household selected.')),
      );
    }

    final membersAsync = ref.watch(householdMembersProvider(household.id));
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final isCreator = currentUser?.uid == household.createdByUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load members',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(
                    householdMembersProvider(household.id),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final isSelf = member.uid == currentUser?.uid;
              final isOwner = member.uid == household.createdByUserId;
               return Card(
                 child: ListTile(
                   onTap: () => context.push(AppRoutes.profileDetailsFor(member.uid)),
                   leading: UserAvatar(
                     photoUrl: member.photoUrl,
                     displayName: member.displayName,
                     radius: 20,
                   ),
                  title: Text(
                    member.displayName +
                        (isSelf ? ' (You)' : '') +
                        (isOwner ? ' · Owner' : ''),
                  ),
                  subtitle: Text(member.email),
                  trailing: isCreator && !isSelf
                      ? IconButton(
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: () => _confirmRemove(
                            context,
                            ref,
                            household.id,
                            member,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    String householdId,
    MemberEntity member,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(householdControllerProvider.notifier)
                  .removeMember(householdId: householdId, userId: member.uid);

              if (!context.mounted) return;

              final state = ref.read(householdControllerProvider);
              if (state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error.toString())),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
