import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/core/routes/app_paths.dart';
import 'package:sandbox/core/widgets/app_shell.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:sandbox/features/auth/presentation/routes/auth_routes.dart';
import 'package:sandbox/features/menu/presentation/routes/menu_routes.dart';

@singleton
class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;

  late final GoRouter router = GoRouter(
    initialLocation: AppPaths.login,
    refreshListenable: _BlocRefreshListenable(_authCubit.stream),
    redirect: (context, state) {
      final authState = _authCubit.state;
      final authenticated = authState.status == AuthStatus.authenticated;
      final loggingIn = state.matchedLocation == AppPaths.login;

      if (!authenticated) return loggingIn ? null : AppPaths.login;
      if (loggingIn) return AppPaths.home;

      final openingAdminSettings = state.matchedLocation == AppPaths.settings;
      if (openingAdminSettings && authState.user?.type != UserType.admin) {
        return AppPaths.home;
      }
      return null;
    },
    routes: [
      ...AuthRoutes.routes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: MenuRoutes.branches,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr('core.somethingWentWrong')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppPaths.login),
              child: Text(context.tr('core.goToLogin')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BlocRefreshListenable extends ChangeNotifier {
  _BlocRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
