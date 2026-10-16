import 'package:go_router/go_router.dart';

import 'package:sandbox/core/routes/app_paths.dart';
import 'package:sandbox/features/auth/presentation/screens/login_screen.dart';

abstract final class AuthRoutes {
  static const name = 'login';

  static final routes = <RouteBase>[
    GoRoute(
      name: name,
      path: AppPaths.login,
      builder: (_, __) => const LoginScreen(),
    ),
  ];
}
