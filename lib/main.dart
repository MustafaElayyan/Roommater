import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase_options.dart';

/// Application entry point.
///
/// Initialises Firebase, then mounts the widget tree inside a [ProviderScope]
/// so that every Riverpod provider is available app-wide.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  var initialized = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    initialized = true;
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase options-based initialization failed; retrying with native '
      'configuration. Error: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  if (initialized) {
    return;
  }

  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase initialization skipped. Add android/app/google-services.json '
      'for package com.example.roommater or run `flutterfire configure`. '
      'Error: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}
