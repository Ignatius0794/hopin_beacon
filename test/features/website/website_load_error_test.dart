import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:qbyt/features/website/presentation/helpers/website_load_error.dart';
import 'package:qbyt/features/website/presentation/bloc/website_browser_cubit.dart';

void main() {
  test('Android DNS failure is an address error, not an offline claim', () {
    final error = WebsiteLoadError.fromResource(const WebResourceError(
        errorCode: -2,
        description: 'net::ERR_NAME_NOT_RESOLVED',
        errorType: WebResourceErrorType.hostLookup));
    expect(error.kind, WebsiteErrorKind.address);
    expect(error.title, 'Website address not found');
  });

  test('host lookup failure with no network is an offline error', () {
    final error = WebsiteLoadError.fromResource(
      const WebResourceError(
        errorCode: -2,
        description: 'net::ERR_NAME_NOT_RESOLVED',
        errorType: WebResourceErrorType.hostLookup,
      ),
      deviceOffline: true,
    );
    expect(error.kind, WebsiteErrorKind.offline);
    expect(error.title, 'No internet connection');
  });

  test('explicit Android and iOS offline signals are connection errors', () {
    for (final error in [
      const WebResourceError(
          errorCode: -2,
          description: 'net::ERR_INTERNET_DISCONNECTED',
          errorType: WebResourceErrorType.hostLookup),
      const WebResourceError(errorCode: -1009, description: 'Offline'),
    ]) {
      expect(
          WebsiteLoadError.fromResource(error).kind, WebsiteErrorKind.offline);
    }
  });

  test('iOS URL errors are classified even without errorType', () {
    for (final entry in {
      -1000: WebsiteErrorKind.address,
      -1003: WebsiteErrorKind.address,
      -1004: WebsiteErrorKind.connection,
      -1001: WebsiteErrorKind.timeout,
      -1202: WebsiteErrorKind.security,
    }.entries) {
      expect(
          WebsiteLoadError.fromResource(WebResourceError(
                  errorCode: entry.key, description: 'Native error'))
              .kind,
          entry.value);
    }
  });

  test('404 is a missing page and 500 is a server error', () {
    expect(WebsiteLoadError.fromHttp(404).title, 'Page not found');
    expect(WebsiteLoadError.fromHttp(500).kind, WebsiteErrorKind.server);
    expect(WebsiteLoadError.fromHttp(403).title, 'Access denied');
  });

  test('address error survives page finish', () async {
    final cubit = WebsiteBrowserCubit('https://missing.example');
    cubit.started('https://missing.example');
    cubit.failed('Check the spelling.',
        title: 'Website address not found', kind: WebsiteErrorKind.address);
    cubit.finished('https://missing.example');
    expect(cubit.state.errorKind, WebsiteErrorKind.address);
    expect(cubit.state.errorTitle, 'Website address not found');
    expect(cubit.state.status, WebsiteBrowserStatus.error);
    await cubit.close();
  });
}
