import 'package:flutter/material.dart';

import '../../../app_theme.dart';

/// Champ de saisie SIGMA : libellé au-dessus, icône optionnelle, style Stitch.
class SigmaTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const SigmaTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: SigmaSpacing.xs, bottom: SigmaSpacing.xs),
          child: Text(
            label,
            style: SigmaText.labelLg.copyWith(color: SigmaColors.onSurfaceVariant),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: obscure ? 1 : maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: SigmaColors.secondary) : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
