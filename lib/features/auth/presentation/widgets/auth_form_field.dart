import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_text_field.dart';

/// A pre-styled form field customised for auth screens.
///
/// Thin wrapper around [AppTextField] that wires common auth-specific
/// validation defaults and avoids repeating boilerplate in every auth screen.
class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
    );
  }
}
