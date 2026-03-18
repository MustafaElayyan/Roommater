import 'package:flutter/material.dart';

/// A branded, full-width elevated button used throughout the app.
///
/// Wraps [ElevatedButton] and enforces the design-system defaults defined in
/// [AppTheme]. Pass [isLoading] to show a progress indicator instead of the
/// label while async work is in progress.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
