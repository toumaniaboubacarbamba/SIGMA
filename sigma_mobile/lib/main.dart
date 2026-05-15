import 'package:flutter/material.dart';
import 'package:sigma_mobile/app_theme.dart';
import 'package:sigma_mobile/app_router.dart';

void main() {
  runApp(const SigmaApp());
}

class SigmaApp extends StatelessWidget {
  const SigmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SIGMA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}