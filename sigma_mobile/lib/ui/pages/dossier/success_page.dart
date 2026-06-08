import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';
import '../../../entities/dossier.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_button.dart';

class SuccessPage extends StatelessWidget {
  final Dossier? dossier;

  const SuccessPage({super.key, this.dossier});

  @override
  Widget build(BuildContext context) {
    final ref = dossier?.numeroReference ?? '—';

    return Scaffold(
      appBar: const AppTopBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SigmaSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: SigmaSpacing.lg),
              Container(
                padding: const EdgeInsets.all(SigmaSpacing.lg),
                decoration: BoxDecoration(
                  color: SigmaColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 64, color: SigmaColors.onPrimaryContainer),
              ),
              const SizedBox(height: SigmaSpacing.lg),
              Text('Demande soumise avec succès !',
                  textAlign: TextAlign.center, style: SigmaText.headlineMd),
              const SizedBox(height: SigmaSpacing.sm),
              Text(
                'Votre dossier a été enregistré et sa classification par l\'IA est en cours.',
                textAlign: TextAlign.center,
                style: SigmaText.bodyLg.copyWith(color: SigmaColors.onSurfaceVariant),
              ),
              const SizedBox(height: SigmaSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SigmaSpacing.md),
                decoration: BoxDecoration(
                  color: SigmaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(SigmaRadius.lg),
                  border: Border.all(color: SigmaColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text('NUMÉRO DE RÉFÉRENCE',
                        style: SigmaText.labelLg
                            .copyWith(color: SigmaColors.secondary)),
                    const SizedBox(height: SigmaSpacing.xs),
                    Text(ref,
                        style: SigmaText.displayLg
                            .copyWith(color: SigmaColors.primaryContainer)),
                  ],
                ),
              ),
              const SizedBox(height: SigmaSpacing.lg),
              _step(Icons.mail, 'Confirmation',
                  'Un accusé de réception vous sera envoyé.'),
              _step(Icons.analytics, 'Examen du dossier',
                  'Nos agents vérifieront vos informations (48–72h).'),
              _step(Icons.notifications_active, 'Notification',
                  'Vous serez alerté à chaque évolution.'),
              const SizedBox(height: SigmaSpacing.lg),
              if (dossier != null)
                SigmaButton(
                  label: 'Voir le suivi du dossier',
                  icon: Icons.timeline,
                  onPressed: () => context.go('/dossier/${dossier!.id}'),
                ),
              const SizedBox(height: SigmaSpacing.sm),
              SigmaButton(
                label: 'Retour à l\'accueil',
                outlined: true,
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(IconData icon, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: SigmaSpacing.sm),
      padding: const EdgeInsets.all(SigmaSpacing.md),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        border: Border.all(color: SigmaColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(SigmaSpacing.sm),
            decoration: BoxDecoration(
              color: SigmaColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SigmaRadius.md),
            ),
            child: Icon(icon, size: 20, color: SigmaColors.primary),
          ),
          const SizedBox(width: SigmaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SigmaText.titleMd),
                const SizedBox(height: 2),
                Text(body,
                    style: SigmaText.bodyMd
                        .copyWith(color: SigmaColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
