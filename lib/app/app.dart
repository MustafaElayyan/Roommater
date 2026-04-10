import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/network/firestore_service.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/household/presentation/controllers/household_controller.dart';
import 'router/app_router.dart';

/// Root application widget.
///
/// Consumes the [appRouterProvider] so that routing is Riverpod-managed and
/// the entire widget tree has access to the provider scope established in
/// [main.dart].
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.detached) return;
    final rememberMe = ref.read(rememberMeProvider);
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (!rememberMe && currentUser != null) {
      unawaited(ref.read(firebaseAuthProvider).signOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(householdBootstrapProvider);

    return MaterialApp.router(
      title: 'Roommater',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
