import 'package:flutter/material.dart';

import '../../../app_theme.dart';

/// Bouton principal SIGMA (rempli ou contour), avec état de chargement.
class SigmaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool outlined;

  const SigmaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              if (icon != null) ...[
                const SizedBox(width: SigmaSpacing.sm),
                Icon(icon, size: 20),
              ],
            ],
          );

    if (outlined) {
      return SizedBox(
        height: 48,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: SigmaColors.primary,
            side: const BorderSide(color: SigmaColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SigmaRadius.lg),
            ),
            textStyle: SigmaText.titleMd,
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: SigmaColors.primary),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label),
                    if (icon != null) ...[
                      const SizedBox(width: SigmaSpacing.sm),
                      Icon(icon, size: 20),
                    ],
                  ],
                ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: child,
      ),
    );
  }
}
