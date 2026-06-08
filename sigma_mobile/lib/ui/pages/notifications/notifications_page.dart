import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';
import '../../../entities/dossier.dart';
import '../../../entities/statut_dossier.dart';
import '../../../repositories/dossier_repository.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_bottom_nav.dart';
import '../../../view_models/dossier/dossier_list_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => DossierListCubit(ctx.read<DossierRepository>())..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(onAvatarTap: () => context.go('/profil')),
      bottomNavigationBar: const SigmaBottomNav(currentIndex: 2),
      body: SafeArea(
        child: BlocBuilder<DossierListCubit, DossierListState>(
          builder: (context, state) {
            if (state.status == DossierListStatus.loading ||
                state.status == DossierListStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            final dossiers = state.dossiers;
            return ListView(
              padding: const EdgeInsets.all(SigmaSpacing.md),
              children: [
                Text('Mes alertes', style: SigmaText.headlineMd),
                const SizedBox(height: SigmaSpacing.xs),
                Text('Suivez l\'évolution de vos dossiers en temps réel.',
                    style: SigmaText.bodyMd
                        .copyWith(color: SigmaColors.onSurfaceVariant)),
                const SizedBox(height: SigmaSpacing.lg),
                if (dossiers.isEmpty)
                  _empty()
                else
                  for (final d in dossiers) ...[
                    _notifCard(context, d),
                    const SizedBox(height: SigmaSpacing.md),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(SigmaSpacing.xl),
      child: Center(
        child: Text('Aucune alerte pour le moment.',
            style: SigmaText.bodyMd.copyWith(color: SigmaColors.secondary)),
      ),
    );
  }

  Widget _notifCard(BuildContext context, Dossier d) {
    final info = DossierStatut.of(d.statut);
    return InkWell(
      onTap: () => context.push('/dossier/${d.id}'),
      borderRadius: BorderRadius.circular(SigmaRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(SigmaSpacing.md),
        decoration: BoxDecoration(
          color: SigmaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SigmaRadius.lg),
          border: Border.all(color: SigmaColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: info.background,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_turned_in, size: 20, color: info.color),
            ),
            const SizedBox(width: SigmaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mise à jour de statut', style: SigmaText.titleMd),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      style: SigmaText.bodyMd
                          .copyWith(color: SigmaColors.onSurfaceVariant),
                      children: [
                        TextSpan(text: 'Dossier ${d.numeroReference ?? '#${d.id}'} → '),
                        TextSpan(
                          text: info.label.toUpperCase(),
                          style: TextStyle(
                              color: info.color, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SigmaColors.secondary),
          ],
        ),
      ),
    );
  }
}
