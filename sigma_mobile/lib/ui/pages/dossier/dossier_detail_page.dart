import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_theme.dart';
import '../../../entities/dossier.dart';
import '../../../entities/statut_dossier.dart';
import '../../../repositories/dossier_repository.dart';
import '../../../view_models/dossier/dossier_detail_cubit.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_category_badge.dart';
import '../../widgets/common/sigma_status_badge.dart';
import '../../widgets/dossier/timeline_step.dart';

class DossierDetailPage extends StatelessWidget {
  final int dossierId;

  const DossierDetailPage({super.key, required this.dossierId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          DossierDetailCubit(ctx.read<DossierRepository>())..load(dossierId),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  static const _descriptions = {
    'SOUMIS': 'Dossier enregistré sur le portail citoyen.',
    'EN_ANALYSE': 'Vérification de la complétude des pièces.',
    'RECEVABLE': 'Dossier conforme aux exigences réglementaires.',
    'SIGNATURE_DIR': 'En attente de signature de la direction.',
    'APPROUVE': 'Décision finale et notification.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(showBack: true),
      body: SafeArea(
        child: BlocBuilder<DossierDetailCubit, DossierDetailState>(
          builder: (context, state) {
            if (state.status == DetailStatus.loading && state.dossier == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == DetailStatus.error) {
              return Center(
                child: Text(state.error ?? 'Erreur',
                    style: SigmaText.bodyMd.copyWith(color: SigmaColors.error)),
              );
            }
            final d = state.dossier!;
            return ListView(
              padding: const EdgeInsets.all(SigmaSpacing.md),
              children: [
                Text('Dossier ${d.numeroReference ?? '#${d.id}'}',
                    style: SigmaText.headlineMd),
                const SizedBox(height: SigmaSpacing.xs),
                Text(
                  d.description ?? 'Demande administrative',
                  style: SigmaText.bodyMd.copyWith(color: SigmaColors.onSurfaceVariant),
                ),
                const SizedBox(height: SigmaSpacing.lg),
                _heroCard(d, state.classificationEnCours),
                const SizedBox(height: SigmaSpacing.lg),
                _timelineCard(d),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _heroCard(Dossier d, bool classifying) {
    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.md),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        border: Border.all(color: SigmaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SigmaStatusBadge(statut: d.statut),
              if (d.dateDepot != null)
                Text(
                  '${d.dateDepot!.day}/${d.dateDepot!.month}/${d.dateDepot!.year}',
                  style: SigmaText.labelMd.copyWith(color: SigmaColors.secondary),
                ),
            ],
          ),
          const Divider(height: SigmaSpacing.lg * 1.5, color: SigmaColors.outlineVariant),
          Text('CLASSIFICATION IA',
              style: SigmaText.labelLg.copyWith(color: SigmaColors.onSurfaceVariant)),
          const SizedBox(height: SigmaSpacing.sm),
          if (d.estClasse)
            SigmaCategoryBadge(
              categorie: d.categorieIa!,
              scorePourcent: d.scorePourcent,
              large: true,
            )
          else
            Row(
              children: [
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: SigmaColors.primary),
                ),
                const SizedBox(width: SigmaSpacing.sm),
                Text(
                  classifying
                      ? 'Analyse en cours par l\'IA…'
                      : 'Non classé',
                  style: SigmaText.bodyMd.copyWith(color: SigmaColors.secondary),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _timelineCard(Dossier d) {
    final currentIdx = DossierStatut.parcoursIndex(d.statut);
    final rejete = d.statut == 'REJETE';

    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.md),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        border: Border.all(color: SigmaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivi de l\'avancement', style: SigmaText.titleLg),
          const SizedBox(height: SigmaSpacing.lg),
          if (rejete)
            Row(
              children: [
                const Icon(Icons.cancel, color: SigmaColors.error),
                const SizedBox(width: SigmaSpacing.sm),
                Expanded(
                  child: Text('Dossier rejeté.',
                      style: SigmaText.bodyMd.copyWith(color: SigmaColors.error)),
                ),
              ],
            )
          else
            for (var i = 0; i < DossierStatut.parcours.length; i++)
              TimelineStep(
                label: DossierStatut.of(DossierStatut.parcours[i]).label,
                description: _descriptions[DossierStatut.parcours[i]] ?? '',
                state: i < currentIdx
                    ? TimelineStepState.done
                    : (i == currentIdx
                        ? TimelineStepState.current
                        : TimelineStepState.upcoming),
                isLast: i == DossierStatut.parcours.length - 1,
              ),
        ],
      ),
    );
  }
}
