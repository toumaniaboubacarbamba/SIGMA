import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_theme.dart';
import '../../../view_models/auth/auth_cubit.dart';
import '../../widgets/common/sigma_button.dart';
import '../../widgets/common/sigma_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.error!),
                  backgroundColor: SigmaColors.error,
                ));
            }
          },
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(SigmaSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: SigmaSpacing.xl),
                  // Logo
                  Column(
                    children: [
                      const Icon(Icons.account_balance,
                          size: 56, color: SigmaColors.primary),
                      const SizedBox(height: SigmaSpacing.sm),
                      Text('SIGMA',
                          style: SigmaText.displayLg.copyWith(
                              color: SigmaColors.primary)),
                    ],
                  ),
                  const SizedBox(height: SigmaSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(SigmaSpacing.lg),
                    decoration: BoxDecoration(
                      color: SigmaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(SigmaRadius.lg),
                      border: Border.all(color: SigmaColors.outlineVariant),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bienvenue', style: SigmaText.headlineMd),
                          const SizedBox(height: SigmaSpacing.xs),
                          Text(
                            'Connectez-vous à votre espace citoyen sécurisé.',
                            style: SigmaText.bodyMd
                                .copyWith(color: SigmaColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: SigmaSpacing.lg),
                          SigmaTextField(
                            label: 'ADRESSE EMAIL',
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
                            label: 'MOT DE PASSE',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            controller: _password,
                            obscure: _obscure,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Mot de passe requis'
                                : null,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              color: SigmaColors.secondary,
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          const SizedBox(height: SigmaSpacing.lg),
                          SigmaButton(
                            label: 'Se connecter',
                            icon: Icons.arrow_forward,
                            loading: loading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: SigmaSpacing.lg),
                          Center(
                            child: Text('OU',
                                style: SigmaText.labelMd
                                    .copyWith(color: SigmaColors.secondary)),
                          ),
                          const SizedBox(height: SigmaSpacing.md),
                          SigmaButton(
                            label: 'Créer un compte citoyen',
                            outlined: true,
                            onPressed: () => context.go('/register'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: SigmaSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user,
                          size: 16, color: SigmaColors.primary),
                      const SizedBox(width: SigmaSpacing.xs),
                      Text(
                        'Connexion sécurisée (chiffrement 256-bit)',
                        style: SigmaText.labelMd
                            .copyWith(color: SigmaColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
