import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_form_field.dart';

/// Screen that allows new users to create a Roommater account.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).signUp(
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
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
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
              const SizedBox(height: 32),
              AppButton(
                label: 'Register',
                onPressed: _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pushReplacement(AppRoutes.login),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
