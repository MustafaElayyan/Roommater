import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Application entry point.
///
/// Mounts the widget tree inside a [ProviderScope] so every Riverpod provider
/// is available app-wide.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
