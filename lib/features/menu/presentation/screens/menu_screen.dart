import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:sandbox/features/menu/presentation/bloc/menu_cubit.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<MenuCubit>().state.status == MenuStatus.initial) {
      context.read<MenuCubit>().load();
    }
  }

  IconData _iconFor(String id) => switch (id) {
        'profile' => Icons.person_outline,
        'settings' => Icons.settings_outlined,
        _ => Icons.home_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthCubit>().state.user?.username ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('menu.home'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              context.tr('menu.helloUser').replaceAll('{name}', username),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(context.tr('menu.chooseItem')),
            const SizedBox(height: 24),
            BlocBuilder<MenuCubit, MenuState>(
              builder: (context, state) => switch (state.status) {
                MenuStatus.initial || MenuStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                MenuStatus.failure => Center(
                    child: Text(context.tr('menu.loadFailed')),
                  ),
                MenuStatus.empty => Center(
                    child: Text(context.tr('menu.empty')),
                  ),
                MenuStatus.success => Column(
                    children: [
                      for (final entry in state.entries)
                        Card(
                          child: ListTile(
                            leading: Icon(_iconFor(entry.id)),
                            title: Text(context.tr(entry.titleKey)),
                          ),
                        ),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
