// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qbyt/features/website/domain/usecases/get_website_menu_tip.dart';
import 'package:qbyt/features/website/domain/usecases/dismiss_website_menu_tip.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_tip_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qbyt/core/exceptions/failures.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/data/datasources/website_local_datasource.dart';
import 'package:qbyt/features/website/data/repositories/website_repository_impl.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/domain/repositories/website_repository.dart';
import 'package:qbyt/features/website/domain/usecases/get_saved_website.dart';
import 'package:qbyt/features/website/domain/usecases/clear_saved_website.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart';
import 'package:qbyt/features/website/domain/usecases/save_website.dart';
import 'package:qbyt/features/website/domain/usecases/get_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/save_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/clear_previous_website.dart';
import 'package:qbyt/features/website/presentation/bloc/website_entry_cubit.dart';
import 'package:qbyt/features/website/presentation/bloc/website_browser_cubit.dart';
import 'package:qbyt/features/website/presentation/helpers/website_identity.dart';
import 'package:qbyt/features/website/presentation/helpers/website_load_error.dart';
import 'package:qbyt/features/website/presentation/helpers/website_page_color.dart';

class _UnavailableRepository implements WebsiteRepository {
  @override
  Future<Either<Failure, bool>> hasSeenMenuTip() async => Left(CacheFailure());
  @override
  Future<Either<Failure, void>> markMenuTipSeen() async => Left(CacheFailure());
  @override
  Future<Either<Failure, void>> clearAddress() async => Left(CacheFailure());
  @override
  Future<Either<Failure, String?>> getSavedAddress() async =>
      Left(CacheFailure());
  @override
  Future<Either<Failure, void>> saveAddress(String address) async =>
      Left(CacheFailure());
  @override
  Future<Either<Failure, String?>> getPreviousAddress() async =>
      Left(CacheFailure());
  @override
  Future<Either<Failure, void>> savePreviousAddress(String address) async =>
      Left(CacheFailure());
  @override
  Future<Either<Failure, void>> clearPreviousAddress() async =>
      Left(CacheFailure());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalizes addresses while preserving path, query and fragment', () {
    expect(
        WebsiteAddress.tryParse(' example.com/path?q=one%20two#section ')
            ?.value,
        'https://example.com/path?q=one%20two#section');
    expect(WebsiteAddress.tryParse('http://localhost:8080/path')?.value,
        'http://localhost:8080/path');
    expect(WebsiteAddress.tryParse('http://192.168.1.20:8080')?.value,
        'http://192.168.1.20:8080');
    expect(WebsiteAddress.tryParse('https://[::1]:8080')?.value,
        'https://[::1]:8080');
  });

  test('rejects malformed and non-website addresses', () {
    for (final value in [
      '',
      '   ',
      'https://',
      'hello world',
      'not-a-url',
      'http://999.999.999.999',
      'https://bad host',
      'javascript:alert(1)',
      'file:///tmp/file',
      'ftp://example.com',
      'https://user:password@example.com',
      'https://example.com:99999',
      'https://-bad.com',
      'https://example..com'
    ]) {
      expect(WebsiteAddress.tryParse(value), isNull, reason: value);
    }
  });

  test('website identity resolves relative icons and decoded Android results',
      () {
    final relative = WebsiteIdentity.fromJavaScriptResult(
      '{"name":" Example ","logo":"/favicon.png"}',
      Uri.parse('https://example.com/account'),
    );
    expect(relative?.name, 'Example');
    expect(relative?.logoUrl, 'https://example.com/favicon.png');

    final encoded = WebsiteIdentity.fromJavaScriptResult(
      '"{\\"name\\":\\"Workspace\\",\\"logo\\":\\"icon.png\\"}"',
      Uri.parse('https://example.com/app/'),
    );
    expect(encoded?.logoUrl, 'https://example.com/app/icon.png');
    final candidates = WebsiteIdentity.fromJavaScriptResult(
      '{"name":"Workspace","logos":["/broken.ico","/logo.png"]}',
      Uri.parse('https://example.com/app/'),
    );
    expect(candidates?.logoUrls, [
      'https://example.com/broken.ico',
      'https://example.com/logo.png',
      'https://example.com/favicon.ico',
    ]);
    final fallback = WebsiteIdentity.fromJavaScriptResult(
      '{"name":"No declared icon","logo":""}',
      Uri.parse('https://example.com/app/'),
    );
    expect(fallback?.logoUrl, 'https://example.com/favicon.ico');
    expect(
      WebsiteIdentity.fromJavaScriptResult('not-json', Uri.parse('https://x')),
      isNull,
    );
  });

  test('website page color accepts safe RGB results and rejects bad values',
      () {
    expect(
      WebsitePageColor.fromJavaScriptResult('[12, 34, 56]'),
      const Color.fromARGB(255, 12, 34, 56),
    );
    expect(
      WebsitePageColor.fromJavaScriptResult('"[255,0,128]"'),
      const Color.fromARGB(255, 255, 0, 128),
    );
    expect(WebsitePageColor.fromJavaScriptResult(''), isNull);
    expect(WebsitePageColor.fromJavaScriptResult('[1, 2]'), isNull);
    expect(WebsitePageColor.fromJavaScriptResult('[1, "bad", 3]'), isNull);
  });

  test('saves normalized address and restores it through a new repository',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository =
        WebsiteRepositoryImpl(WebsiteLocalDataSource(preferences));
    expect(
        (await SaveWebsite(repository)(' example.com/a?q=1 '))
            .getOrElse(() => ''),
        'https://example.com/a?q=1');
    final restored = WebsiteRepositoryImpl(WebsiteLocalDataSource(preferences));
    expect((await GetSavedWebsite(restored)(NoParams())).getOrElse(() => null),
        'https://example.com/a?q=1');
    expect((await SaveWebsite(repository)('file:///x')).isLeft(), isTrue);
    expect((await GetSavedWebsite(restored)(NoParams())).getOrElse(() => null),
        'https://example.com/a?q=1');
  });

  test('ignores invalid saved addresses', () async {
    SharedPreferences.setMockInitialValues(
        {WebsiteLocalDataSource.addressKey: 'file:///x'});
    final repository = WebsiteRepositoryImpl(
        WebsiteLocalDataSource(await SharedPreferences.getInstance()));
    expect(
        (await GetSavedWebsite(repository)(NoParams()))
            .getOrElse(() => 'failed'),
        isNull);
  });

  test('entry reports persistence errors without navigating', () async {
    final repository = _UnavailableRepository();
    final cubit =
        WebsiteEntryCubit(GetSavedWebsite(repository), SaveWebsite(repository));
    await cubit.restore();
    expect(cubit.state.status, WebsiteEntryStatus.error);
    await cubit.open('https://example.com');
    expect(cubit.state.status, WebsiteEntryStatus.error);
    expect(cubit.state.error, contains('Could not save'));
    await cubit.close();
  });

  test(
      'menu tip starts hidden, shows after success only once, and survives URL reset',
      () async {
    SharedPreferences.setMockInitialValues({});
    final repository = WebsiteRepositoryImpl(
        WebsiteLocalDataSource(await SharedPreferences.getInstance()));
    final claim = GetWebsiteMenuTip(repository);
    final first = WebsiteMenuTipCubit(claim, DismissWebsiteMenuTip(repository));
    expect(first.state, isFalse);
    await first.showAfterSuccess();
    expect(first.state, isTrue);
    await first.dismiss();
    expect(first.state, isFalse);
    await first.showAfterSuccess();
    expect(first.state, isFalse);
    await first.close();
    await ClearSavedWebsite(repository)(NoParams());
    final nextLaunch =
        WebsiteMenuTipCubit(claim, DismissWebsiteMenuTip(repository));
    await nextLaunch.showAfterSuccess();
    expect(nextLaunch.state, isFalse);
    await nextLaunch.close();
  });

  test('tip is not consumed until acknowledged', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = WebsiteRepositoryImpl(
        WebsiteLocalDataSource(await SharedPreferences.getInstance()));
    final first = WebsiteMenuTipCubit(
        GetWebsiteMenuTip(repository), DismissWebsiteMenuTip(repository));
    await first.showAfterSuccess();
    expect(first.state, isTrue);
    await first.close();
    final reopened = WebsiteMenuTipCubit(
        GetWebsiteMenuTip(repository), DismissWebsiteMenuTip(repository));
    await reopened.showAfterSuccess();
    expect(reopened.state, isTrue);
    await reopened.dismiss();
    expect((await repository.hasSeenMenuTip()).getOrElse(() => false), isTrue);
    await reopened.close();
  });

  test('fragment changes and implicit root paths do not leave loading stuck',
      () async {
    final cubit = WebsiteBrowserCubit('https://example.com');
    cubit.started('https://example.com');
    cubit.locationChanged('https://example.com/#section');
    cubit.finished('https://example.com/');
    expect(cubit.state.status, WebsiteBrowserStatus.ready);
    expect(cubit.state.url, 'https://example.com/#section');
    await cubit.close();
  });

  test('retrying a replacement URL restores the full loading state', () async {
    final cubit = WebsiteBrowserCubit('https://old.example.com');
    cubit.finished('https://old.example.com');
    expect(cubit.state.hasLoadedPage, isTrue);

    cubit.started(
      'https://new.example.com',
      resetLoadedPage: true,
      intent: WebsiteLoadingIntent.changing,
    );

    expect(cubit.state.url, 'https://new.example.com');
    expect(cubit.state.status, WebsiteBrowserStatus.loading);
    expect(cubit.state.hasLoadedPage, isFalse);
    expect(cubit.state.loadingIntent, WebsiteLoadingIntent.changing);
    await cubit.close();
  });

  test('a later connection failure preserves the last successful page',
      () async {
    final cubit = WebsiteBrowserCubit('https://example.com/working');
    cubit.finished('https://example.com/working');

    cubit.started('https://example.com/unavailable');
    cubit.failed(
      'No internet connection.',
      url: 'https://example.com/unavailable',
      isMainFrame: true,
      kind: WebsiteErrorKind.offline,
    );

    expect(cubit.state.status, WebsiteBrowserStatus.ready);
    expect(cubit.state.url, 'https://example.com/working');
    expect(cubit.state.hasLoadedPage, isTrue);
    expect(cubit.state.resourceWarning, contains('last loaded page'));
    await cubit.close();
  });

  test('a cached service-worker page can recover after an offline error',
      () async {
    final cubit = WebsiteBrowserCubit('https://example.com/offline');
    cubit.started('https://example.com/offline');
    cubit.failed(
      'No internet connection.',
      url: 'https://example.com/offline',
      isMainFrame: true,
      kind: WebsiteErrorKind.offline,
    );
    expect(cubit.state.status, WebsiteBrowserStatus.error);

    cubit.finished('https://example.com/offline');

    expect(cubit.state.status, WebsiteBrowserStatus.ready);
    expect(cubit.state.hasLoadedPage, isTrue);
    expect(cubit.state.message, isNull);
    await cubit.close();
  });

  test('a replacement URL cannot turn Android offline error page into success',
      () async {
    final cubit = WebsiteBrowserCubit('https://youtube.com');
    cubit.started(
      'https://youtube.com',
      resetLoadedPage: true,
      intent: WebsiteLoadingIntent.changing,
    );
    cubit.failed(
      WebsiteLoadError.offline.message,
      title: WebsiteLoadError.offline.title,
      kind: WebsiteErrorKind.offline,
      url: 'https://youtube.com',
      isMainFrame: true,
      preserveLoadedPage: false,
      allowOfflineRecovery: false,
    );

    // Android finishes its generated net::ERR_INTERNET_DISCONNECTED page.
    cubit.finished('https://youtube.com');

    expect(cubit.state.status, WebsiteBrowserStatus.error);
    expect(cubit.state.errorKind, WebsiteErrorKind.offline);
    await cubit.close();
  });

  test('failure uses full error state when the previous page cannot be shown',
      () async {
    final cubit = WebsiteBrowserCubit('https://example.com/working');
    cubit.finished('https://example.com/working');
    cubit.started('https://example.com/unavailable');

    cubit.failed(
      'No internet connection.',
      url: 'https://example.com/unavailable',
      isMainFrame: true,
      kind: WebsiteErrorKind.offline,
      preserveLoadedPage: false,
    );

    expect(cubit.state.status, WebsiteBrowserStatus.error);
    expect(cubit.state.message, 'No internet connection.');
    await cubit.close();
  });

  test('opening the menu before page success suppresses the tip', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = WebsiteRepositoryImpl(
        WebsiteLocalDataSource(await SharedPreferences.getInstance()));
    final tip = WebsiteMenuTipCubit(
        GetWebsiteMenuTip(repository), DismissWebsiteMenuTip(repository));
    await tip.dismiss();
    await tip.showAfterSuccess();
    expect(tip.state, isFalse);
    expect((await repository.hasSeenMenuTip()).getOrElse(() => false), isTrue);
    await tip.close();
  });

  test('tip preference failure does not interrupt browsing', () async {
    final tip = WebsiteMenuTipCubit(GetWebsiteMenuTip(_UnavailableRepository()),
        DismissWebsiteMenuTip(_UnavailableRepository()));
    await tip.showAfterSuccess();
    expect(tip.state, isTrue);
    await tip.close();
  });

  test('failed reset reports an error rather than returning to the menu',
      () async {
    final repository = _UnavailableRepository();
    final cubit = WebsiteMenuCubit(
      ClearSavedWebsite(repository),
      SaveWebsite(repository),
      GetPreviousWebsite(repository),
      SavePreviousWebsite(repository),
      ClearPreviousWebsite(repository),
    );
    await cubit.resetUrl();
    expect(cubit.state, WebsiteMenuState.error);
    await cubit.close();
  });

  test('URL changes keep a rollback address until load confirmation', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = WebsiteRepositoryImpl(
      WebsiteLocalDataSource(await SharedPreferences.getInstance()),
    );
    final cubit = WebsiteMenuCubit(
      ClearSavedWebsite(repository),
      SaveWebsite(repository),
      GetPreviousWebsite(repository),
      SavePreviousWebsite(repository),
      ClearPreviousWebsite(repository),
    );

    final changed = await cubit.changeUrl(
      'new.example.com/app',
      previousUrl: 'https://old.example.com/',
    );
    expect(changed.address, 'https://new.example.com/app');
    expect(await cubit.loadPreviousUrl(), 'https://old.example.com/');

    await cubit.confirmChangedUrlLoaded();
    expect(await cubit.loadPreviousUrl(), isNull);
    await cubit.close();
  });

  test('subresource failures are ignored and main-frame errors survive finish',
      () async {
    final cubit = WebsiteBrowserCubit('https://example.com');
    cubit.started('https://example.com');
    cubit.failed('image failed',
        url: 'https://example.com/image', isMainFrame: false);
    expect(cubit.state.status, WebsiteBrowserStatus.loading);
    cubit.failed('fragment failure',
        url: 'https://example.com/#section', isMainFrame: true);
    expect(cubit.state.status, WebsiteBrowserStatus.error);
    cubit.started('https://example.com');
    cubit.failed('404', url: 'https://example.com/image');
    expect(cubit.state.status, WebsiteBrowserStatus.loading);
    cubit.failed('offline', url: 'https://example.com', isMainFrame: true);
    cubit.finished('https://example.com');
    expect(cubit.state.status, WebsiteBrowserStatus.error);
    cubit.started('https://example.com/account');
    cubit.finished('https://example.com');
    expect(cubit.state.status, WebsiteBrowserStatus.loading);
    cubit.finished('https://example.com/account');
    expect(cubit.state.status, WebsiteBrowserStatus.ready);
    expect(cubit.state.url, 'https://example.com/account');
    await cubit.close();
  });

  testWidgets('late success recovers from timeout', (tester) async {
    final cubit = WebsiteBrowserCubit('https://example.com');
    cubit.started('https://example.com');
    await tester.pump(const Duration(seconds: 21));
    expect(cubit.state.status, WebsiteBrowserStatus.error);
    cubit.finished('https://example.com');
    expect(cubit.state.status, WebsiteBrowserStatus.ready);
    await cubit.close();
  });
}
