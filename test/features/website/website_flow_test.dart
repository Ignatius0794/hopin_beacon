// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qbyt/core/presentation/bloc/app_locale_cubit.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/features/website/domain/usecases/get_website_menu_tip.dart';
import 'package:qbyt/features/website/domain/usecases/dismiss_website_menu_tip.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_tip_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qbyt/core/di/injection.dart';
import 'package:qbyt/core/presentation/screens/splash_screen.dart';
import 'package:qbyt/features/website/data/datasources/website_local_datasource.dart';
import 'package:qbyt/features/website/data/repositories/website_repository_impl.dart';
import 'package:qbyt/features/website/domain/usecases/get_saved_website.dart';
import 'package:qbyt/features/website/domain/usecases/clear_saved_website.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart';
import 'package:qbyt/features/website/presentation/widgets/website_menu_edge.dart';
import 'package:qbyt/features/website/domain/usecases/save_website.dart';
import 'package:qbyt/features/website/domain/usecases/get_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/save_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/clear_previous_website.dart';
import 'package:qbyt/features/website/presentation/bloc/website_entry_cubit.dart';
import 'package:qbyt/features/website/presentation/routes/website_routes.dart';
import 'package:qbyt/features/website/presentation/screen/website_change_url_screen.dart';

void main() {
  Future<void> openMenu(WidgetTester tester) async {
    final edge = tester.getRect(find.byType(WebsiteMenuEdge));
    await tester.dragFrom(edge.center, const Offset(-120, 0));
    await tester.pumpAndSettle();
  }

  Future<GoRouter> setup(
    WidgetTester tester, {
    String? saved,
    String initial = '/splash',
  }) async {
    SharedPreferences.setMockInitialValues({
      if (saved != null) WebsiteLocalDataSource.addressKey: saved,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = WebsiteRepositoryImpl(
      WebsiteLocalDataSource(preferences),
    );
    getIt.registerFactory<WebsiteMenuCubit>(
      () => WebsiteMenuCubit(
        ClearSavedWebsite(repository),
        SaveWebsite(repository),
        GetPreviousWebsite(repository),
        SavePreviousWebsite(repository),
        ClearPreviousWebsite(repository),
      ),
    );
    getIt.registerFactory<WebsiteMenuTipCubit>(
      () => WebsiteMenuTipCubit(
        GetWebsiteMenuTip(repository),
        DismissWebsiteMenuTip(repository),
      ),
    );
    final getSaved = GetSavedWebsite(repository);
    getIt.registerSingleton<GetSavedWebsite>(getSaved);
    getIt.registerFactory<WebsiteEntryCubit>(
      () => WebsiteEntryCubit(getSaved, SaveWebsite(repository)),
    );
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => SplashScreen(getSavedWebsite: getSaved),
        ),
        ...WebsiteRoutes.routes,
      ],
    );
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppLocaleCubit(preferences),
        child: MaterialApp.router(
          routerConfig: router,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            appLocalizationsDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await getIt.reset();
    });
    return router;
  }

  testWidgets('first launch asks for a URL, validates, saves and opens it', (
    tester,
  ) async {
    final router = await setup(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/main');
    await tester.enterText(find.byType(TextFormField), 'file:///tmp/test');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid HTTP or HTTPS website address.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(TextFormField),
      'example.com/account?q=1',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/web');
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(WebsiteLocalDataSource.addressKey),
      'https://example.com/account?q=1',
    );
    expect(find.byType(AppBar), findsNothing);
    await openMenu(tester);
    expect(find.text('Reload page'), findsOneWidget);
    expect(find.text('Change URL'), findsOneWidget);
    expect(find.text('Forget website'), findsOneWidget);
    expect(find.text('https://example.com/account?q=1'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    await tester.tap(find.text('Reload page'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/web');
    expect(find.text('Reload page'), findsNothing);
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));

  testWidgets(
    'Change URL can be cancelled without leaving or changing the saved URL',
    (tester) async {
      final router = await setup(tester, saved: 'http://example.com/path');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/web');
      expect(find.text('Open in browser'), findsOneWidget);
      await openMenu(tester);
      await tester.tap(find.text('Change URL'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/web');
      expect(find.byType(WebsiteChangeUrlScreen), findsOneWidget);
      expect(find.text('Current website'), findsOneWidget);
      expect(find.byTooltip('Copy current URL'), findsOneWidget);
      await tester.tap(find.byTooltip('Copy current URL'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('http://example.com/path'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        isEmpty,
      );
      await tester.tap(find.byTooltip('Cancel and return to website'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/web');
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(WebsiteLocalDataSource.addressKey),
        'http://example.com/path',
      );
    },
    variant: TargetPlatformVariant({TargetPlatform.linux}),
  );

  testWidgets('Change URL validates and persists the replacement address', (
    tester,
  ) async {
    final router = await setup(tester, saved: 'https://example.com/old');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/web');
    await openMenu(tester);
    await tester.tap(find.text('Change URL'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'file:///tmp/test');
    await tester.tap(find.text('Change website'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid HTTP or HTTPS website address.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), 'new.example.com/app');
    await tester.tap(find.text('Change website'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/web');
    expect(find.text('Current website'), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(WebsiteLocalDataSource.addressKey),
      'https://new.example.com/app',
    );
    expect(
      preferences.getString(WebsiteLocalDataSource.previousAddressKey),
      'https://example.com/old',
    );

    // A fresh launch opens the replacement automatically and retains the
    // rollback address until a native WebView confirms a successful load.
    router.go('/splash');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/web');
    expect(find.text('Open in browser'), findsOneWidget);
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));

  testWidgets('Forget website confirms and clears the URL for next launch', (
    tester,
  ) async {
    final router = await setup(tester, saved: 'https://example.com/company');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/web');
    final edge = tester.getRect(find.byType(WebsiteMenuEdge));
    await tester.dragFrom(edge.center, const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(find.text('Reload page'), findsNothing);
    await openMenu(tester);
    await tester.tap(find.text('Forget website'));
    await tester.pumpAndSettle();
    expect(find.text('Forget this website?'), findsOneWidget);
    await tester.tap(find.text('Forget website').last);
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/main');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(WebsiteLocalDataSource.addressKey), isNull);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      isEmpty,
    );
    router.go('/splash');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/main');
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));

  testWidgets('invalid saved URL falls back to entry', (tester) async {
    final router = await setup(tester, saved: 'javascript:bad()');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/main');
  }, variant: TargetPlatformVariant({TargetPlatform.linux}));
}
