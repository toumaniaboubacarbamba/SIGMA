import 'package:flutter/material.dart';

import '../../../app_theme.dart';

/// TopAppBar SIGMA : logo institutionnel + nom + avatar citoyen.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onAvatarTap;

  const AppTopBar({super.key, this.showBack = false, this.onAvatarTap});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      titleSpacing: showBack ? 0 : SigmaSpacing.md,
      title: Row(
        children: [
          const Icon(Icons.account_balance, color: SigmaColors.primary),
          const SizedBox(width: SigmaSpacing.sm),
          Text(
            'SIGMA',
            style: SigmaText.titleLg.copyWith(
              color: SigmaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: SigmaSpacing.md),
          child: GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: SigmaColors.surfaceContainerHigh,
              child: const Icon(Icons.person, size: 18, color: SigmaColors.secondary),
            ),
          ),
        ),
      ],
    );
  }
}
