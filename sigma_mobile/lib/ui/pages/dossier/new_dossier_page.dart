import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';
import '../../../entities/dossier.dart';
import '../../../repositories/dossier_repository.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_bottom_nav.dart';
import '../../widgets/common/sigma_button.dart';

class NewDossierPage extends StatefulWidget {
  const NewDossierPage({super.key});

  @override
  State<NewDossierPage> createState() => _NewDossierPageState();
}

class _NewDossierPageState extends State<NewDossierPage> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final Dossier created = await context
          .read<DossierRepository>()
          .create(description: _description.text.trim());
      if (!mounted) return;
      context.go('/succes', extra: created);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Échec de la soumission. Réessayez.'),
          backgroundColor: SigmaColors.error,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(showBack: true),
      bottomNavigationBar: const SigmaBottomNav(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SigmaSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nouveau dossier', style: SigmaText.headlineMd),
                const SizedBox(height: SigmaSpacing.xs),
                Text(
                  'Décrivez votre demande : notre IA la classera automatiquement.',
                  style: SigmaText.bodyMd.copyWith(color: SigmaColors.onSurfaceVariant),
                ),
                const SizedBox(height: SigmaSpacing.lg),
                _card(
                  icon: Icons.info_outline,
                  title: 'Informations générales',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DESCRIPTION DE LA DEMANDE',
                          style: SigmaText.labelLg
                              .copyWith(color: SigmaColors.onSurfaceVariant)),
                      const SizedBox(height: SigmaSpacing.xs),
                      TextFormField(
                        controller: _description,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Ex : Demande de permis de construire pour une maison à Cocody…',
                        ),
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? 'Décrivez votre demande (10 caractères min.)'
                            : null,
                      ),
                      const SizedBox(height: SigmaSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 16, color: SigmaColors.primary),
                          const SizedBox(width: SigmaSpacing.xs),
                          Expanded(
                            child: Text(
                              'La catégorie sera détectée automatiquement par l\'IA.',
                              style: SigmaText.labelMd
                                  .copyWith(color: SigmaColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SigmaSpacing.md),
                _card(
                  icon: Icons.attach_file,
                  title: 'Pièces jointes',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(SigmaSpacing.lg),
                    decoration: BoxDecoration(
                      color: SigmaColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(SigmaRadius.lg),
                      border: Border.all(
                        color: SigmaColors.outlineVariant,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined,
                            size: 40, color: SigmaColors.secondary),
                        const SizedBox(height: SigmaSpacing.sm),
                        Text('Téléverser un document',
                            style: SigmaText.titleMd),
                        const SizedBox(height: SigmaSpacing.xs),
                        Text('PDF, PNG ou JPG (5 Mo max)',
                            style: SigmaText.labelMd
                                .copyWith(color: SigmaColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SigmaSpacing.lg),
                SigmaButton(
                  label: 'Soumettre ma demande',
                  icon: Icons.send,
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: SigmaSpacing.sm),
                SigmaButton(
                  label: 'Annuler',
                  outlined: true,
                  onPressed: () => context.go('/dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required IconData icon, required String title, required Widget child}) {
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
            children: [
              Icon(icon, color: SigmaColors.primaryContainer),
              const SizedBox(width: SigmaSpacing.sm),
              Text(title, style: SigmaText.titleMd),
            ],
          ),
          const SizedBox(height: SigmaSpacing.md),
          child,
        ],
      ),
    );
  }
}
