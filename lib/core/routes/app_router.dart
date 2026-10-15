import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'package:qbyt/core/presentation/screens/error_screen.dart';
import 'package:qbyt/core/presentation/screens/splash_screen.dart';
import 'package:qbyt/features/website/domain/usecases/get_saved_website.dart';
import 'package:qbyt/features/website/presentation/routes/website_routes.dart';

@injectable
class AppRouter {
  AppRouter(this._getSavedWebsite);

  final GetSavedWebsite _getSavedWebsite;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splashPath,
    routes: _buildRoutes(),
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error?.toString(),
    ),
  );

  static const splashName = 'splash';
  static const splashPath = '/splash';

  List<RouteBase> _buildRoutes() => [
        _buildSplashRoute(),
        ...WebsiteRoutes.routes,
      ];

  GoRoute _buildSplashRoute() => GoRoute(
        name: splashName,
        path: splashPath,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: SplashScreen(getSavedWebsite: _getSavedWebsite),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
}
