import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sandbox/core/routes/app_paths.dart';
import 'package:sandbox/features/menu/presentation/screens/menu_screen.dart';
import 'package:sandbox/features/menu/presentation/screens/profile_screen.dart';
import 'package:sandbox/features/menu/presentation/screens/settings_screen.dart';

abstract final class MenuRoutes {
  static const homeName = 'home';
  static const profileName = 'profile';
  static const settingsName = 'settings';

  static final branches = <StatefulShellBranch>[
    StatefulShellBranch(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'homeBranch'),
      routes: [
        GoRoute(
          name: homeName,
          path: AppPaths.home,
          builder: (_, __) => const MenuScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'profileBranch'),
      routes: [
        GoRoute(
          name: profileName,
          path: AppPaths.profile,
          builder: (_, __) => const ProfileScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'settingsBranch'),
      routes: [
        GoRoute(
          name: settingsName,
          path: AppPaths.settings,
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),
  ];
}
