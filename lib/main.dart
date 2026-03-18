import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Application entry point.
///
/// Initialises Firebase, then mounts the widget tree inside a [ProviderScope]
/// so that every Riverpod provider is available app-wide.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is initialised from the platform-specific google-services.json /
  // GoogleService-Info.plist files.  No secrets are hardcoded in Dart.
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
