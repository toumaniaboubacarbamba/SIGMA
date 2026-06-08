import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_theme.dart';
import '../../../view_models/auth/auth_cubit.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_bottom_nav.dart';
import '../../widgets/common/sigma_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthCubit>().state.email ?? 'citoyen@sigma.ci';
    final nom = _nomFromEmail(email);

    return Scaffold(
      appBar: const AppTopBar(),
      bottomNavigationBar: const SigmaBottomNav(currentIndex: 3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SigmaSpacing.md),
          children: [
            // En-tête profil
            Container(
              padding: const EdgeInsets.symmetric(vertical: SigmaSpacing.xl),
              decoration: BoxDecoration(
                color: SigmaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(SigmaRadius.lg),
                border: Border.all(color: SigmaColors.outlineVariant),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SigmaColors.primaryContainer, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: SigmaColors.surfaceContainerHigh,
                      child: Icon(Icons.person, size: 40, color: SigmaColors.secondary),
                    ),
                  ),
                  const SizedBox(height: SigmaSpacing.md),
                  Text(nom, style: SigmaText.headlineMd),
                  const SizedBox(height: 2),
                  Text(email,
                      style: SigmaText.labelLg.copyWith(color: SigmaColors.secondary)),
                ],
              ),
            ),
            const SizedBox(height: SigmaSpacing.lg),
            Text('Informations personnelles',
                style: SigmaText.titleMd),
            const SizedBox(height: SigmaSpacing.sm),
            _infoTile(Icons.mail_outline, 'E-mail', email),
            const SizedBox(height: SigmaSpacing.lg),
            Text('Sécurité', style: SigmaText.titleMd),
            const SizedBox(height: SigmaSpacing.sm),
            _actionTile(Icons.lock_reset, 'Changer le mot de passe'),
            const SizedBox(height: SigmaSpacing.xl),
            SigmaButton(
              label: 'Se déconnecter',
              icon: Icons.logout,
              outlined: true,
              onPressed: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
      ),
    );
  }

  String _nomFromEmail(String email) {
    final local = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.md),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        border: Border.all(color: SigmaColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: SigmaColors.secondary),
          const SizedBox(width: SigmaSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: SigmaText.labelMd.copyWith(color: SigmaColors.secondary)),
              Text(value, style: SigmaText.bodyLg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(SigmaSpacing.md),
      decoration: BoxDecoration(
        color: SigmaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SigmaRadius.lg),
        border: Border.all(color: SigmaColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: SigmaColors.secondary),
          const SizedBox(width: SigmaSpacing.md),
          Expanded(child: Text(label, style: SigmaText.bodyLg)),
          const Icon(Icons.chevron_right, color: SigmaColors.outline),
        ],
      ),
    );
  }
}
