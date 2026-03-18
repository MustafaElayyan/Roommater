import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks home-tab index and exposes any home-level state.
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
