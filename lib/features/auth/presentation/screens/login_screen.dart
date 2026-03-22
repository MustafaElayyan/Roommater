import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_form_field.dart';

/// Screen that allows existing users to sign in with email and password.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static const Color _actionTextColor = AppColors.primary;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    authState.whenOrNull(
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      ),
      data: (_) => context.go(AppRoutes.noHousehold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              AuthFormField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your email' : null,
              ),
              const SizedBox(height: 16),
              AuthFormField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Min 8 characters' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password reset is not available yet.',
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _actionTextColor,
                    minimumSize: const Size(120, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Sign In',
                onPressed: _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pushReplacement(AppRoutes.register),
                style: TextButton.styleFrom(
                  foregroundColor: _actionTextColor,
                ),
                child: const Text("Don't have account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
