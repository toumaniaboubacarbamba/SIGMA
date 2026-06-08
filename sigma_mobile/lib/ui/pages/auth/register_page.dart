import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';
import '../../../repositories/auth_repository.dart';
import '../../../view_models/auth/auth_cubit.dart';
import '../../widgets/common/app_top_bar.dart';
import '../../widgets/common/sigma_button.dart';
import '../../widgets/common/sigma_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _tel = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _accept = false;
  bool _loading = false;

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _tel.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_accept) {
      _snack('Veuillez accepter les conditions d\'utilisation.', SigmaColors.error);
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthRepository>().register(
            nomComplet: _nom.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            telephone: _tel.text.trim(),
          );
      if (!mounted) return;
      // Connexion automatique après inscription.
      await context.read<AuthCubit>().login(_email.text.trim(), _password.text);
    } on AuthException catch (e) {
      if (mounted) _snack(e.message, SigmaColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SigmaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Créer un compte citoyen', style: SigmaText.headlineMd),
              const SizedBox(height: SigmaSpacing.xs),
              Text(
                'Gérez vos démarches administratives en toute sécurité.',
                style: SigmaText.bodyLg.copyWith(color: SigmaColors.secondary),
              ),
              const SizedBox(height: SigmaSpacing.lg),
              Container(
                padding: const EdgeInsets.all(SigmaSpacing.md),
                decoration: BoxDecoration(
                  color: SigmaColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(SigmaRadius.lg),
                  border: Border.all(color: SigmaColors.outlineVariant),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SigmaTextField(
                        label: 'Nom complet',
                        hint: 'Ex : Koffi Kouassi Jean',
                        icon: Icons.person_outline,
                        controller: _nom,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: SigmaSpacing.md),
                      SigmaTextField(
                        label: 'Adresse e-mail',
                        hint: 'nom@exemple.ci',
                        icon: Icons.mail_outline,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Email invalide'
                            : null,
                      ),
                      const SizedBox(height: SigmaSpacing.md),
                      SigmaTextField(
                        label: 'Numéro de téléphone',
                        hint: '+225 01 02 03 04 05',
                        icon: Icons.phone_iphone,
                        controller: _tel,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: SigmaSpacing.md),
                      SigmaTextField(
                        label: 'Mot de passe',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: _password,
                        obscure: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? '6 caractères minimum'
                            : null,
                      ),
                      const SizedBox(height: SigmaSpacing.md),
                      SigmaTextField(
                        label: 'Confirmer le mot de passe',
                        hint: '••••••••',
                        icon: Icons.lock_clock_outlined,
                        controller: _confirm,
                        obscure: true,
                        validator: (v) =>
                            v != _password.text ? 'Les mots de passe diffèrent' : null,
                      ),
                      const SizedBox(height: SigmaSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _accept,
                            onChanged: (v) => setState(() => _accept = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                "J'accepte les conditions d'utilisation et la politique de confidentialité.",
                                style: SigmaText.bodyMd
                                    .copyWith(color: SigmaColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SigmaSpacing.md),
                      SigmaButton(
                        label: 'Créer mon compte',
                        icon: Icons.arrow_forward,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SigmaSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Vous avez déjà un compte ? Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
