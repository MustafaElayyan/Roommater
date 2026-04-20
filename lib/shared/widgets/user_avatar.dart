import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.displayName,
    this.radius = 20,
    this.onTap,
  });

  final String? photoUrl;
  final String displayName;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = photoUrl?.trim();
    final hasPhoto = normalizedUrl != null && normalizedUrl.isNotEmpty;
    final fallback = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : '?';

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: hasPhoto
          ? ClipOval(
              child: Image.network(
                normalizedUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallbackText(fallback),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: radius * 2,
                    height: radius * 2,
                    child: Center(
                      child: SizedBox(
                        width: radius,
                        height: radius,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticLabel: 'Loading profile photo',
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : _fallbackText(fallback),
    );

    if (onTap == null) return avatar;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: avatar,
    );
  }

  Widget _fallbackText(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
