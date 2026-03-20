import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeTabIndexProvider = StateProvider<int>((ref) => 0);
final homeTaskChecksProvider = StateProvider<List<bool>>(
  (ref) => <bool>[false, true, false],
);
