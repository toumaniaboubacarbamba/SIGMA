import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';
import '../../../repositories/dossier_repository.dart';
import '../../../view_models/auth/auth_cubit.dart';
import '../../../view_models/dossier/dossier_list_cubit.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_bottom_nav.dart';
import '../../widgets/dossier/dossier_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          DossierListCubit(ctx.read<DossierRepository>())..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthCubit>().state.email ?? 'citoyen';
    final prenom = email.split('@').first;

    return Scaffold(
      appBar: AppTopBar(onAvatarTap: () => context.go('/profil')),
      bottomNavigationBar: const SigmaBottomNav(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DossierListCubit>().load(),
          child: BlocBuilder<DossierListCubit, DossierListState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(SigmaSpacing.md),
                children: [
                  _hero(prenom),
                  const SizedBox(height: SigmaSpacing.lg),
                  _stats(state),
                  const SizedBox(height: SigmaSpacing.lg),
                  Text('Mes dossiers récents', style: SigmaText.titleLg),
                  const SizedBox(height: SigmaSpacing.md),
                  ..._buildList(context, state),
                  const SizedBox(height: SigmaSpacing.lg),
                  _banner(context),
                  const SizedBox(height: SigmaSpacing.lg),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hero(String prenom) {
    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.lg),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        border: Border.all(color: SigmaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenue, $prenom',
              style: SigmaText.headlineMd.copyWith(color: SigmaColors.primary)),
          const SizedBox(height: SigmaSpacing.xs),
          Text(
            'Suivez l\'avancement de vos dossiers en temps réel.',
            style: SigmaText.bodyMd.copyWith(color: SigmaColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _stats(DossierListState state) {
    return Row(
      children: [
        _statCard('En cours', state.enCours, SigmaColors.primary),
        const SizedBox(width: SigmaSpacing.sm),
        _statCard('Approuvés', state.approuves, SigmaColors.primary),
        const SizedBox(width: SigmaSpacing.sm),
        _statCard('Alertes', state.rejetes, SigmaColors.error),
        const SizedBox(width: SigmaSpacing.sm),
        _statCard('Total', state.total, SigmaColors.onSurface),
      ],
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(SigmaSpacing.gutter),
        decoration: BoxDecoration(
          color: SigmaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(SigmaRadius.md),
          border: Border.all(color: SigmaColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: SigmaText.labelMd.copyWith(color: SigmaColors.secondary)),
            const SizedBox(height: SigmaSpacing.xs),
            Text(value.toString().padLeft(2, '0'),
                style: SigmaText.displayLg.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, DossierListState state) {
    switch (state.status) {
      case DossierListStatus.loading:
      case DossierListStatus.initial:
        return [
          const Padding(
            padding: EdgeInsets.all(SigmaSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      case DossierListStatus.error:
        return [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(SigmaSpacing.lg),
              child: Text(state.error ?? 'Erreur',
                  style: SigmaText.bodyMd.copyWith(color: SigmaColors.error)),
            ),
          ),
        ];
      case DossierListStatus.loaded:
        if (state.dossiers.isEmpty) {
          return [_emptyState()];
        }
        return [
          for (final d in state.dossiers) ...[
            DossierCard(
              dossier: d,
              onTap: () => context.push('/dossier/${d.id}'),
            ),
            const SizedBox(height: SigmaSpacing.md),
          ],
        ];
    }
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.folder_open_outlined,
              size: 48, color: SigmaColors.outline),
          const SizedBox(height: SigmaSpacing.sm),
          Text('Aucun dossier pour le moment.',
              style: SigmaText.bodyMd.copyWith(color: SigmaColors.secondary)),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.lg),
      decoration: BoxDecoration(
        color: SigmaColors.primaryContainer,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nouveau dossier ?',
                    style: SigmaText.titleMd
                        .copyWith(color: SigmaColors.onPrimaryContainer)),
                const SizedBox(height: SigmaSpacing.xs),
                Text('Initiez une démarche en quelques clics.',
                    style: SigmaText.bodyMd
                        .copyWith(color: SigmaColors.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(width: SigmaSpacing.sm),
          FilledButton(
            onPressed: () => context.go('/nouvelle-demande'),
            style: FilledButton.styleFrom(
              backgroundColor: SigmaColors.onPrimaryContainer,
              foregroundColor: SigmaColors.primary,
            ),
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }
}
