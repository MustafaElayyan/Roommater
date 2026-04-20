import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/network/firestore_service.dart';
import '../controllers/auth_controller.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  static const int _cooldownSeconds = 30;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isSigningOut = false;

  Future<void> _signOutAndGoToAuthChoice() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      context.go(AppRoutes.authChoice);
    } catch (error, stackTrace) {
      debugPrint('Email verification sign-out failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign out. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        return;
      }
      setState(() => _secondsRemaining -= 1);
    });
  }

  Future<void> _resendEmail() async {
    await ref.read(authControllerProvider.notifier).resendEmailVerification();
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
      return;
    }
    _startCooldown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email resent.')),
    );
  }

  Future<void> _checkVerification() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go(AppRoutes.authChoice);
      return;
    }

    await user.reload();
    final refreshed = auth.currentUser;
    if (!mounted) return;
    if (refreshed?.emailVerified ?? false) {
      context.go(AppRoutes.noHousehold);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email not yet verified.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final email = ref.watch(authStateProvider).valueOrNull?.email ??
        ref.read(firebaseAuthProvider).currentUser?.email ??
        'your email';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && !_isSigningOut) {
          _signOutAndGoToAuthChoice();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Email Verification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isSigningOut ? null : _signOutAndGoToAuthChoice,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'A verification email has been sent to $email. Please check your inbox.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLoading || _secondsRemaining > 0 ? null : _resendEmail,
                child: Text(
                  _secondsRemaining > 0
                      ? 'Resend Email ($_secondsRemaining)'
                      : 'Resend Email',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _checkVerification,
                child: const Text("I've Verified My Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
