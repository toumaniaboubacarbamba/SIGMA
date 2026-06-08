import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';
import 'app_theme.dart';
import 'engines/api_client.dart';
import 'engines/token_storage.dart';
import 'repositories/auth_repository.dart';
import 'repositories/dossier_repository.dart';
import 'view_models/auth/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final authRepository = AuthRepository(apiClient, tokenStorage);
  final dossierRepository = DossierRepository(apiClient);

  runApp(SigmaApp(
    authRepository: authRepository,
    dossierRepository: dossierRepository,
  ));
}

class SigmaApp extends StatelessWidget {
  final AuthRepository authRepository;
  final DossierRepository dossierRepository;

  const SigmaApp({
    super.key,
    required this.authRepository,
    required this.dossierRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: dossierRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(authRepository)..check(),
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            final router = AppRouter.create(authCubit);
            return MaterialApp.router(
              title: 'SIGMA',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
