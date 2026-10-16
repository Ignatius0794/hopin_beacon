import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/core/presentation/bloc/app_locale_cubit.dart';
import 'package:sandbox/core/presentation/bloc/app_theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = context.watch<AppThemeCubit>().state == ThemeMode.dark;
    final languageCode = context.watch<AppLocaleCubit>().state.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('menu.settings'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SwitchListTile(
            value: darkMode,
            onChanged: context.read<AppThemeCubit>().setDarkMode,
            secondary: Icon(darkMode ? Icons.dark_mode : Icons.light_mode),
            title: Text(context.tr('menu.darkMode'))),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(context.tr('core.language')),
          trailing: DropdownButton<String>(
            value: languageCode,
            onChanged: (value) {
              if (value != null) {
                context.read<AppLocaleCubit>().changeLanguage(value);
              }
            },
            items: [
              DropdownMenuItem(
                  value: 'en', child: Text(context.tr('core.english'))),
              DropdownMenuItem(
                  value: 'ms', child: Text(context.tr('core.malay')))
            ],
          ),
        ),
      ]),
    );
  }
}
