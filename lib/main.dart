import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sandbox/bloc/app_bloc_observer.dart';
import 'package:sandbox/core/di/injection.dart';
import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/core/presentation/bloc/app_locale_cubit.dart';
import 'package:sandbox/core/presentation/bloc/app_theme_cubit.dart';
import 'package:sandbox/core/routes/app_router.dart';
import 'package:sandbox/core/theme/app_theme.dart';
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:sandbox/features/menu/presentation/bloc/menu_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<AppLocaleCubit>()),
        BlocProvider(create: (_) => getIt<AppThemeCubit>()),
        BlocProvider(create: (_) => getIt<MenuCubit>()),
      ],
      child: BlocBuilder<AppLocaleCubit, Locale>(
        builder: (context, locale) => BlocBuilder<AppThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.tr('core.appName'),
            theme: getIt<AppTheme>().light,
            darkTheme: getIt<AppTheme>().dark,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              appLocalizationsDelegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: getIt<AppRouter>().router,
          ),
        ),
      ),
    );
  }
}
