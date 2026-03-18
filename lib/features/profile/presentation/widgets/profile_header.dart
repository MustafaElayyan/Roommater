import 'package:flutter/material.dart';

import '../../domain/entities/profile_entity.dart';

/// Displays the user's avatar, name, and occupation in the profile screen header.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: profile.photoUrl != null
              ? NetworkImage(profile.photoUrl!)
              : null,
          child: profile.photoUrl == null
              ? const Icon(Icons.person, size: 48)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (profile.occupation != null) ...[
          const SizedBox(height: 4),
          Text(
            profile.occupation!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (profile.location != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Text(
                profile.location!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
