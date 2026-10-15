import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qbyt/features/website/presentation/helpers/website_load_error.dart';

enum WebsiteBrowserStatus { loading, ready, error }

enum WebsiteLoadingIntent { opening, retrying, changing, restoring }

class WebsiteBrowserState extends Equatable {
  const WebsiteBrowserState({
    required this.url,
    this.status = WebsiteBrowserStatus.loading,
    this.message,
    this.errorTitle,
    this.errorKind = WebsiteErrorKind.general,
    this.progress = 0,
    this.hasLoadedPage = false,
    this.resourceWarning,
    this.websiteName,
    this.websiteLogoUrls = const [],
    WebsiteLoadingIntent loadingIntent = WebsiteLoadingIntent.opening,
  }) : _loadingIntent = loadingIntent;

  final String url;
  final WebsiteBrowserStatus status;
  final String? message;
  final String? errorTitle;
  final WebsiteErrorKind errorKind;
  final int progress;
  final bool hasLoadedPage;
  final String? resourceWarning;
  final String? websiteName;
  final List<String> websiteLogoUrls;
  // Nullable internally so a state object retained across hot reload can
  // safely fall back when this field did not exist in the previous class.
  final WebsiteLoadingIntent? _loadingIntent;
  WebsiteLoadingIntent get loadingIntent =>
      _loadingIntent ?? WebsiteLoadingIntent.opening;

  WebsiteBrowserState copyWith({
    String? url,
    WebsiteBrowserStatus? status,
    String? message,
    String? errorTitle,
    bool clearError = false,
    WebsiteErrorKind? errorKind,
    int? progress,
    bool? hasLoadedPage,
    String? resourceWarning,
    bool clearResourceWarning = false,
    String? websiteName,
    List<String>? websiteLogoUrls,
    bool clearIdentity = false,
    WebsiteLoadingIntent? loadingIntent,
  }) {
    return WebsiteBrowserState(
      url: url ?? this.url,
      status: status ?? this.status,
      message: clearError ? null : message ?? this.message,
      errorTitle: clearError ? null : errorTitle ?? this.errorTitle,
      errorKind:
          errorKind ?? (clearError ? WebsiteErrorKind.general : this.errorKind),
      progress: progress ?? this.progress,
      hasLoadedPage: hasLoadedPage ?? this.hasLoadedPage,
      resourceWarning:
          clearResourceWarning ? null : resourceWarning ?? this.resourceWarning,
      websiteName: clearIdentity ? null : websiteName ?? this.websiteName,
      websiteLogoUrls:
          clearIdentity ? const [] : websiteLogoUrls ?? this.websiteLogoUrls,
      loadingIntent: loadingIntent ?? this.loadingIntent,
    );
  }

  @override
  List<Object?> get props => [
        url,
        status,
        message,
        errorTitle,
        errorKind,
        progress,
        hasLoadedPage,
        resourceWarning,
        websiteName,
        websiteLogoUrls,
        loadingIntent,
      ];
}

/// Presentation state only; the screen owns the platform WebView controller.
class WebsiteBrowserCubit extends Cubit<WebsiteBrowserState> {
  WebsiteBrowserCubit(
    String url, {
    this.loadTimeout = const Duration(seconds: 20),
  }) : super(WebsiteBrowserState(url: url));
  final Duration loadTimeout;
  Timer? _timer;
  bool _failed = false;
  String? _lastSuccessfulUrl;

  void started(
    String url, {
    bool resetLoadedPage = false,
    WebsiteLoadingIntent? intent,
  }) {
    if (isClosed) return;
    _failed = false;
    _timer?.cancel();
    emit(state.copyWith(
      url: url,
      status: WebsiteBrowserStatus.loading,
      progress: 0,
      hasLoadedPage: resetLoadedPage ? false : state.hasLoadedPage,
      clearError: true,
      clearResourceWarning: true,
      clearIdentity: true,
      loadingIntent: intent,
    ));
    _timer = Timer(loadTimeout, () {
      if (isClosed) return;
      // A timeout does not invalidate a later successful completion.
      if (state.hasLoadedPage && _lastSuccessfulUrl != null) {
        emit(state.copyWith(
          url: _lastSuccessfulUrl,
          status: WebsiteBrowserStatus.ready,
          progress: 100,
          clearError: true,
          resourceWarning:
              'The new page took too long to load. The last loaded page is still available.',
        ));
        return;
      }
      emit(state.copyWith(
        status: WebsiteBrowserStatus.error,
        errorTitle: WebsiteLoadError.timeout.title,
        errorKind: WebsiteErrorKind.timeout,
        message: WebsiteLoadError.timeout.message,
      ));
    });
  }

  static String _documentUrl(String url) {
    final uri = Uri.parse(url);
    return uri
        .replace(fragment: '', path: uri.path.isEmpty ? '/' : uri.path)
        .toString();
  }

  void finished(String url) {
    if (isClosed || _failed || _documentUrl(url) != _documentUrl(state.url)) {
      return;
    }
    _timer?.cancel();
    _lastSuccessfulUrl = state.url;
    emit(state.copyWith(
      status: WebsiteBrowserStatus.ready,
      progress: 100,
      hasLoadedPage: true,
      clearError: true,
      clearResourceWarning: true,
      loadingIntent: WebsiteLoadingIntent.opening,
    ));
  }

  void failed(
    String message, {
    String? url,
    bool? isMainFrame,
    String? title,
    WebsiteErrorKind kind = WebsiteErrorKind.general,
    bool preserveLoadedPage = true,
    bool allowOfflineRecovery = true,
  }) {
    if (isClosed ||
        isMainFrame == false ||
        (url != null && _documentUrl(url) != _documentUrl(state.url))) {
      return;
    }
    // A service worker can still complete the navigation from its cache after
    // the native WebView reports that the network is offline. Other failures
    // remain final so an error page cannot masquerade as a successful load.
    _failed = kind != WebsiteErrorKind.offline || !allowOfflineRecovery;
    _timer?.cancel();
    if (preserveLoadedPage &&
        state.hasLoadedPage &&
        _lastSuccessfulUrl != null) {
      emit(state.copyWith(
        url: _lastSuccessfulUrl,
        status: WebsiteBrowserStatus.ready,
        progress: 100,
        clearError: true,
        resourceWarning: kind == WebsiteErrorKind.offline
            ? 'You are offline. The last loaded page is still available.'
            : 'The new page could not load. The last loaded page is still available.',
      ));
      return;
    }
    emit(state.copyWith(
      status: WebsiteBrowserStatus.error,
      message: message,
      errorTitle: title,
      errorKind: kind,
    ));
  }

  void locationChanged(String url) {
    if (isClosed) return;
    emit(state.copyWith(url: url));
  }

  void progressChanged(int progress) {
    if (isClosed) return;
    emit(state.copyWith(progress: progress.clamp(0, 100)));
  }

  void resourceFailed(String? url) {
    if (isClosed || url == null || url == state.url) return;
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (!path.endsWith('.css') && !path.endsWith('.js')) return;
    emit(state.copyWith(
      resourceWarning:
          'Some styles or scripts could not load. The page may look incomplete. Try Reload page from the menu.',
    ));
  }

  void dismissResourceWarning() {
    if (isClosed) return;
    emit(state.copyWith(clearResourceWarning: true));
  }

  void identityChanged({String? name, List<String> logoUrls = const []}) {
    if (isClosed) return;
    emit(state.copyWith(websiteName: name, websiteLogoUrls: logoUrls));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
