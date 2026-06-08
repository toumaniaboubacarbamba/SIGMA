import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../entities/statut_dossier.dart';

/// Badge de catégorie prédite par l'IA, avec score de confiance.
///
/// C'est l'élément vedette du module IA : icône « auto_awesome » + catégorie
/// + pourcentage (ex: ✨ Permis de construire · 98%).
class SigmaCategoryBadge extends StatelessWidget {
  final String categorie;
  final int? scorePourcent;
  final bool large;

  const SigmaCategoryBadge({
    super.key,
    required this.categorie,
    this.scorePourcent,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = CategorieIa.of(categorie);
    final accent = SigmaColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? SigmaSpacing.md : SigmaSpacing.gutter,
        vertical: large ? SigmaSpacing.sm : SigmaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SigmaRadius.full),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: large ? 18 : 14, color: accent),
          const SizedBox(width: SigmaSpacing.xs),
          Icon(info.icon, size: large ? 18 : 14, color: accent),
          const SizedBox(width: SigmaSpacing.xs),
          Flexible(
            child: Text(
              info.label,
              overflow: TextOverflow.ellipsis,
              style: (large ? SigmaText.labelLg : SigmaText.labelMd).copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (scorePourcent != null) ...[
            const SizedBox(width: SigmaSpacing.xs),
            Text(
              '· $scorePourcent%',
              style: (large ? SigmaText.labelLg : SigmaText.labelMd).copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
