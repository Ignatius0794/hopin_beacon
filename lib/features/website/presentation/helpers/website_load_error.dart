import 'package:webview_flutter/webview_flutter.dart';

enum WebsiteErrorKind {
  address,
  offline,
  connection,
  timeout,
  security,
  server,
  general
}

/// Converts platform WebView failures into actionable presentation messages.
class WebsiteLoadError {
  const WebsiteLoadError(this.kind, this.title, this.message);
  final WebsiteErrorKind kind;
  final String title;
  final String message;

  static const timeout = WebsiteLoadError(
      WebsiteErrorKind.timeout,
      'Website took too long',
      'The website did not respond in time. Try again in a moment.');

  static const offline = WebsiteLoadError(
      WebsiteErrorKind.offline,
      'No internet connection',
      'Connect to Wi-Fi or mobile data, then tap Retry.');

  factory WebsiteLoadError.fromResource(
    WebResourceError error, {
    bool deviceOffline = false,
  }) {
    // These platform signals explicitly mean offline. DNS failures alone do not.
    if (deviceOffline ||
        error.errorCode == -1009 ||
        error.description.toUpperCase().contains('ERR_INTERNET_DISCONNECTED')) {
      return offline;
    }
    // WKWebView leaves errorType null for Foundation URL-loading errors.
    final type = error.errorType ??
        switch (error.errorCode) {
          -1000 => WebResourceErrorType.badUrl,
          -1002 => WebResourceErrorType.unsupportedScheme,
          -1003 || -1006 => WebResourceErrorType.hostLookup,
          -1004 || -1005 => WebResourceErrorType.connect,
          -1001 => WebResourceErrorType.timeout,
          -1007 => WebResourceErrorType.redirectLoop,
          -1200 ||
          -1201 ||
          -1202 ||
          -1203 ||
          -1204 ||
          -1205 ||
          -1206 =>
            WebResourceErrorType.failedSslHandshake,
          _ => null,
        };
    switch (type) {
      case WebResourceErrorType.badUrl:
      case WebResourceErrorType.unsupportedScheme:
        return const WebsiteLoadError(
            WebsiteErrorKind.address,
            'Invalid website address',
            'Check the URL and use an HTTP or HTTPS website address.');
      case WebResourceErrorType.hostLookup:
        return const WebsiteLoadError(
            WebsiteErrorKind.address,
            'Website address not found',
            'Check the spelling of the website address. If it is correct, the website or DNS service may be unavailable.');
      case WebResourceErrorType.timeout:
        return timeout;
      case WebResourceErrorType.failedSslHandshake:
      case WebResourceErrorType.unsafeResource:
        return const WebsiteLoadError(
            WebsiteErrorKind.security,
            'Cannot open this website safely',
            'The website failed a security check. Check the address or contact the website owner.');
      case WebResourceErrorType.connect:
      case WebResourceErrorType.io:
        return const WebsiteLoadError(
            WebsiteErrorKind.connection,
            'Could not connect to website',
            'The connection failed. Check your internet connection. If other websites work, this website may be unavailable.');
      case WebResourceErrorType.redirectLoop:
        return const WebsiteLoadError(
            WebsiteErrorKind.server,
            'Website keeps redirecting',
            'This website is redirecting too many times. Try another address or contact the website owner.');
      default:
        return const WebsiteLoadError(
            WebsiteErrorKind.general,
            'Could not load website',
            'Try again or check the website address.');
    }
  }

  factory WebsiteLoadError.fromHttp(int? code) {
    if (code == 404 || code == 410) {
      return const WebsiteLoadError(WebsiteErrorKind.address, 'Page not found',
          'This page does not exist or has moved. Check the full URL, including the path after the website name.');
    }
    if (code == 401 || code == 403) {
      return const WebsiteLoadError(WebsiteErrorKind.server, 'Access denied',
          'This website requires permission or sign-in. Check the address or contact the website owner.');
    }
    return WebsiteLoadError(
        WebsiteErrorKind.server,
        'Website returned an error',
        'The website returned an error${code == null ? '' : ' ($code)'}. Please try again later.');
  }
}
