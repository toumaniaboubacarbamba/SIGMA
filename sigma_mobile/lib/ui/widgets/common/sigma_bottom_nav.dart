import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';

/// Barre de navigation basse du portail citoyen.
class SigmaBottomNav extends StatelessWidget {
  /// 0 = Accueil, 1 = Nouveau, 2 = Alertes, 3 = Profil
  final int currentIndex;

  const SigmaBottomNav({super.key, required this.currentIndex});

  static const _items = [
    (icon: Icons.home_outlined, active: Icons.home, label: 'Accueil', route: '/dashboard'),
    (icon: Icons.add_box_outlined, active: Icons.add_box, label: 'Nouveau', route: '/nouvelle-demande'),
    (icon: Icons.notifications_outlined, active: Icons.notifications, label: 'Alertes', route: '/notifications'),
    (icon: Icons.person_outline, active: Icons.person, label: 'Profil', route: '/profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SigmaColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(SigmaRadius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SigmaSpacing.gutter, vertical: SigmaSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++) _buildItem(context, i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final selected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!selected) context.go(item.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? SigmaSpacing.md : SigmaSpacing.sm,
          vertical: SigmaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? SigmaColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(SigmaRadius.full),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.active : item.icon,
              size: 22,
              color: selected ? SigmaColors.onPrimaryContainer : SigmaColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: SigmaText.labelMd.copyWith(
                color: selected ? SigmaColors.onPrimaryContainer : SigmaColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
