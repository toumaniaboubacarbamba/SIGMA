import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../entities/statut_dossier.dart';

/// Pastille de statut de dossier (couleurs alignées sur la charte Stitch).
class SigmaStatusBadge extends StatelessWidget {
  final String statut;

  const SigmaStatusBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final info = DossierStatut.of(statut);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SigmaSpacing.gutter, vertical: SigmaSpacing.xs),
      decoration: BoxDecoration(
        color: info.background,
        borderRadius: BorderRadius.circular(SigmaRadius.full),
      ),
      child: Text(
        info.label.toUpperCase(),
        style: SigmaText.labelMd.copyWith(
          color: info.color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
