import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../entities/dossier.dart';
import '../../../entities/statut_dossier.dart';
import '../common/sigma_category_badge.dart';
import '../common/sigma_status_badge.dart';

/// Carte d'un dossier dans la liste du tableau de bord.
class DossierCard extends StatelessWidget {
  final Dossier dossier;
  final VoidCallback? onTap;

  const DossierCard({super.key, required this.dossier, this.onTap});

  String get _titre {
    if (dossier.estClasse) return CategorieIa.of(dossier.categorieIa!).label;
    return 'Dossier administratif';
  }

  String get _dateLabel {
    final d = dossier.dateDepot;
    if (d == null) return '';
    const mois = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jui', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return 'Déposé le ${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(SigmaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_titre, style: SigmaText.titleMd),
                        const SizedBox(height: 2),
                        Text(
                          'Réf : ${dossier.numeroReference ?? '—'}',
                          style: SigmaText.labelLg.copyWith(color: SigmaColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  SigmaStatusBadge(statut: dossier.statut),
                ],
              ),
              const SizedBox(height: SigmaSpacing.sm),
              // Badge IA ou état "classification en cours"
              if (dossier.estClasse)
                SigmaCategoryBadge(
                  categorie: dossier.categorieIa!,
                  scorePourcent: dossier.scorePourcent,
                )
              else
                Row(
                  children: [
                    const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: SigmaColors.primary),
                    ),
                    const SizedBox(width: SigmaSpacing.sm),
                    Text(
                      'Classification IA en cours…',
                      style: SigmaText.labelMd.copyWith(color: SigmaColors.secondary),
                    ),
                  ],
                ),
              const SizedBox(height: SigmaSpacing.gutter),
              const Divider(height: 1, color: SigmaColors.outlineVariant),
              const SizedBox(height: SigmaSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: SigmaColors.onSurfaceVariant),
                  const SizedBox(width: SigmaSpacing.xs),
                  Text(
                    _dateLabel,
                    style: SigmaText.bodyMd.copyWith(color: SigmaColors.onSurfaceVariant),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: SigmaColors.secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
