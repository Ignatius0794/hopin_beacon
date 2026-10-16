import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/core/routes/app_paths.dart';
import 'package:sandbox/features/auth/domain/entities/app_user.dart';
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('menu.profile')),
        actions: [
          IconButton(
              tooltip: context.tr('menu.logout'),
              onPressed: () {
                context.read<AuthCubit>().logout();
                context.go(AppPaths.login);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(
              radius: 40, child: Icon(Icons.person_outline, size: 40)),
          const SizedBox(height: 16),
          Text(user?.username ?? '',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(user?.type == UserType.admin
              ? context.tr('menu.roleAdmin')
              : context.tr('menu.roleMember')),
        ]),
      ),
    );
  }
}
