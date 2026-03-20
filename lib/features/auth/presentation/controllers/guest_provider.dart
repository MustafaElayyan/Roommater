import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the current session is a guest (unauthenticated) session.
///
/// Defaults to `false`. Set to `true` when the user taps "Continue as Guest"
/// on the [AuthChoiceScreen]. Other features can watch this provider to
/// conditionally disable write-operations that require authentication.
final isGuestProvider = StateProvider<bool>((ref) => false);
