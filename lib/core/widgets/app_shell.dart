import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<_ShellDestination> _destinationsFor(UserType type) => [
        const _ShellDestination(
          branchIndex: 0,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          labelKey: 'menu.home',
        ),
        const _ShellDestination(
          branchIndex: 1,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          labelKey: 'menu.profile',
        ),
        if (type == UserType.admin)
          const _ShellDestination(
            branchIndex: 2,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            labelKey: 'menu.settings',
          ),
      ];

  void _selectDestination(_ShellDestination destination) {
    widget.navigationShell.goBranch(
      destination.branchIndex,
      initialLocation:
          destination.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    final destinations = _destinationsFor(user.type);
    final selectedIndex = destinations.indexWhere(
      (destination) =>
          destination.branchIndex == widget.navigationShell.currentIndex,
    );

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) =>
            _selectDestination(destinations[index]),
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: context.tr(destination.labelKey),
            ),
        ],
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.branchIndex,
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
  });

  final int branchIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
}
