import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qbyt/bloc/app_bloc_observer.dart';
import 'package:qbyt/core/di/injection.dart';
import 'package:qbyt/core/presentation/bloc/app_locale_cubit.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/routes/app_router.dart';
import 'package:qbyt/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await configureDependencies();

    Bloc.observer = AppBlocObserver();
    runApp(const App());
  } catch (e) {
    debugPrint('Initialization error: $e');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app. Please restart.\n\n'
            'Aplikasi gagal dimulakan. Sila mulakan semula.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appTheme = AppTheme();
  late final AppRouter _appRouter = getIt<AppRouter>();
  late final AppLocaleCubit _localeCubit =
      AppLocaleCubit(getIt<SharedPreferences>());

  @override
  void dispose() {
    _appRouter.router.dispose();
    _localeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _localeCubit,
      child: BlocBuilder<AppLocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'QBYT',
          theme: _appTheme.light,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            appLocalizationsDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
