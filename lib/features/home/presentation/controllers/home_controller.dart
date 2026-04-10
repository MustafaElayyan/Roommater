import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/presentation/controllers/task_controller.dart';

final homeTabIndexProvider = StateProvider<int>((ref) => 0);

final homeTaskChecksProvider = Provider<Map<String, bool>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
  return {for (final task in tasks) task.id: task.isCompleted};
});
