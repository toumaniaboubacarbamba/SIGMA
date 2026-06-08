import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'entities/dossier.dart';
import 'ui/pages/auth/login_page.dart';
import 'ui/pages/auth/register_page.dart';
import 'ui/pages/dashboard/dashboard_page.dart';
import 'ui/pages/dossier/dossier_detail_page.dart';
import 'ui/pages/dossier/new_dossier_page.dart';
import 'ui/pages/dossier/success_page.dart';
import 'ui/pages/notifications/notifications_page.dart';
import 'ui/pages/profile/profile_page.dart';
import 'view_models/auth/auth_cubit.dart';

class AppRouter {
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final status = authCubit.state.status;
        if (status == AuthStatus.unknown) return null;

        final loggedIn = status == AuthStatus.authenticated;
        final loc = state.matchedLocation;
        final onAuthPage = loc == '/login' || loc == '/register';

        if (!loggedIn && !onAuthPage) return '/login';
        if (loggedIn && onAuthPage) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
        GoRoute(path: '/register', builder: (c, s) => const RegisterPage()),
        GoRoute(path: '/dashboard', builder: (c, s) => const DashboardPage()),
        GoRoute(
          path: '/nouvelle-demande',
          builder: (c, s) => const NewDossierPage(),
        ),
        GoRoute(
          path: '/succes',
          builder: (c, s) => SuccessPage(dossier: s.extra as Dossier?),
        ),
        GoRoute(
          path: '/dossier/:id',
          builder: (c, s) => DossierDetailPage(
            dossierId: int.parse(s.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (c, s) => const NotificationsPage(),
        ),
        GoRoute(path: '/profil', builder: (c, s) => const ProfilePage()),
      ],
    );
  }
}

/// Permet à go_router de réagir aux changements d'état d'authentification.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
