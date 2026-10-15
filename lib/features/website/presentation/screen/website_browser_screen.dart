import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/core/widgets/neo_toast.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/presentation/bloc/website_browser_cubit.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_tip_cubit.dart';
import 'package:qbyt/features/website/presentation/helpers/website_load_error.dart';
import 'package:qbyt/features/website/presentation/helpers/website_navigation_policy.dart';
import 'package:qbyt/features/website/presentation/helpers/website_page_inspector.dart';
import 'package:qbyt/features/website/presentation/routes/website_routes.dart';
import 'package:qbyt/features/website/presentation/screen/website_change_url_screen.dart';
import 'package:qbyt/features/website/presentation/widgets/website_browser_menu.dart';
import 'package:qbyt/features/website/presentation/widgets/website_browser_view.dart';

class WebsiteBrowserScreen extends StatefulWidget {
  const WebsiteBrowserScreen({super.key, required this.url});
  final String url;

  @override
  State<WebsiteBrowserScreen> createState() => _WebsiteBrowserScreenState();
}

class _WebsiteBrowserScreenState extends State<WebsiteBrowserScreen> {
  late final WebsiteBrowserCubit _browser;
  WebViewController? _controller;
  bool _navigatingBack = false;
  bool _initializing = false;
  bool _leaving = false;
  bool _menuOpen = false;
  bool _restoringPrevious = false;
  bool _canReturnToPreviousPage = false;
  Color _pageBackgroundColor = style.scaffoldBackgroundColor;
  late String _trustedUrl;
  String? _previousUrl;
  String? _pendingChangedUrl;
  bool _pendingChangedUrlHadError = false;
  Timer? _menuTipTimer;
  Timer? _changedUrlConfirmationTimer;
  Timer? _restoreRevealTimer;
  final Connectivity _connectivity = Connectivity();

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();
    _trustedUrl = widget.url;
    _browser = WebsiteBrowserCubit(widget.url);
    unawaited(_loadPendingPreviousUrl());
    _initialize();
  }

  Future<void> _loadPendingPreviousUrl() async {
    final previous = await context.read<WebsiteMenuCubit>().loadPreviousUrl();
    if (!mounted || previous == null || previous == widget.url) return;
    if (_browser.state.status == WebsiteBrowserStatus.ready) {
      await context.read<WebsiteMenuCubit>().confirmChangedUrlLoaded();
      return;
    }
    setState(() {
      _previousUrl = previous;
      _pendingChangedUrl = widget.url;
      _canReturnToPreviousPage = true;
    });
  }

  Future<void> _initialize() async {
    if (_initializing || !mounted || _leaving) return;
    if (!_supported) {
      _browser.failed(
          'An embedded browser is unavailable on this platform. Open the website in your browser instead.');
      return;
    }
    _initializing = true;
    _browser.started(widget.url);
    try {
      final controller = WebViewController(
        onPermissionRequest: _handleWebPermissionRequest,
      );
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      final platformController = controller.platform;
      if (platformController is AndroidWebViewController) {
        final cookieManager = WebViewCookieManager().platform;
        if (cookieManager is AndroidWebViewCookieManager) {
          await cookieManager.setAcceptThirdPartyCookies(
            platformController,
            true,
          );
        }
        await platformController.setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            try {
              final origin = Uri.tryParse(request.origin);
              if (origin == null ||
                  !WebsiteNavigationPolicy.sameOrigin(
                    origin,
                    Uri.parse(_trustedUrl),
                  )) {
                return const GeolocationPermissionsResponse(
                  allow: false,
                  retain: false,
                );
              }
              final status = await Permission.locationWhenInUse.request();
              return GeolocationPermissionsResponse(
                allow: status.isGranted,
                retain: false,
              );
            } catch (_) {
              return const GeolocationPermissionsResponse(
                allow: false,
                retain: false,
              );
            }
          },
        );
      }
      if (!mounted || _leaving) {
        await _stopLoading(controller);
        return;
      }
      await controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (!mounted || _leaving) return NavigationDecision.prevent;
          final uri = Uri.tryParse(request.url);
          if (uri != null && WebsiteAddress.isWebUri(uri)) {
            if (request.isMainFrame &&
                WebsiteNavigationPolicy.looksLikeDownload(uri)) {
              unawaited(_openExternal(uri));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          }
          if (!request.isMainFrame) return NavigationDecision.prevent;
          if (uri != null && WebsiteNavigationPolicy.canOpenExternally(uri)) {
            unawaited(_openExternal(uri));
          } else {
            _notice('This type of link cannot be opened here.');
          }
          return NavigationDecision.prevent;
        },
        onPageStarted: (url) {
          if (!mounted || _leaving) return;
          _menuTipTimer?.cancel();
          if (_pageBackgroundColor != style.scaffoldBackgroundColor) {
            setState(
              () => _pageBackgroundColor = style.scaffoldBackgroundColor,
            );
          }
          _browser.started(url);
        },
        onUrlChange: (change) {
          if (!mounted || _leaving) return;
          final uri = Uri.tryParse(change.url ?? '');
          if (uri != null && WebsiteAddress.isWebUri(uri)) {
            _browser.locationChanged(uri.toString());
          }
        },
        onProgress: (progress) {
          if (!mounted || _leaving) return;
          _browser.progressChanged(progress);
        },
        onPageFinished: (url) => unawaited(_handlePageFinished(url)),
        onWebResourceError: (error) =>
            unawaited(_handleWebResourceError(error)),
        onHttpError: (error) {
          if (!mounted || _leaving) return;
          // Subresource HTTP errors must not replace the whole page.
          final url = error.request?.uri.toString();
          if (url == null) return;
          _reportResourceFailure(url, 'HTTP ${error.response?.statusCode}');
          final failure = WebsiteLoadError.fromHttp(error.response?.statusCode);
          if (_restoringPrevious &&
              WebsiteNavigationPolicy.sameDocument(
                url,
                _browser.state.url,
              )) {
            _restoreRevealTimer?.cancel();
            setState(() => _restoringPrevious = false);
          }
          _browser.failed(failure.message,
              title: failure.title, kind: failure.kind, url: url);
        },
      ));
      if (!mounted || _leaving) {
        await _stopLoading(controller);
        return;
      }
      setState(() => _controller = controller);
      await controller.loadRequest(Uri.parse(widget.url));
    } catch (_) {
      _browser.failed(
          'The browser could not start. Please try again or change the address.');
    } finally {
      _initializing = false;
    }
  }

  void _scheduleMenuTip() {
    _menuTipTimer?.cancel();
    _menuTipTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted ||
          _leaving ||
          _browser.state.status != WebsiteBrowserStatus.ready) {
        return;
      }
      context.read<WebsiteMenuTipCubit>().showAfterSuccess();
    });
  }

  void _handleWebPermissionRequest(WebViewPermissionRequest request) {
    unawaited(_resolveWebPermissionRequest(request));
  }

  Future<void> _resolveWebPermissionRequest(
    WebViewPermissionRequest request,
  ) async {
    try {
      final currentUrl = await _controller?.currentUrl();
      final currentUri = currentUrl == null ? null : Uri.tryParse(currentUrl);
      final trustedUri = Uri.parse(_trustedUrl);
      if (currentUri == null ||
          !WebsiteNavigationPolicy.sameOrigin(currentUri, trustedUri)) {
        await request.deny();
        return;
      }
      var allowed = true;
      for (final type in request.types) {
        final status = switch (type) {
          WebViewPermissionResourceType.camera =>
            await Permission.camera.request(),
          WebViewPermissionResourceType.microphone =>
            await Permission.microphone.request(),
          _ => PermissionStatus.denied,
        };
        if (!status.isGranted) allowed = false;
      }
      if (allowed) {
        await request.grant();
      } else {
        await request.deny();
      }
    } catch (_) {
      try {
        await request.deny();
      } catch (_) {
        // The platform request may already have been completed or disposed.
      }
      _notice('Could not request this website permission.');
    }
  }

  void _reportResourceFailure(String? url, String reason) {
    final uri = url == null ? null : Uri.tryParse(url);
    _browser.resourceFailed(url);
    if (kDebugMode && uri != null) {
      debugPrint(
          'WebView resource failed: ${uri.replace(query: '', fragment: '', userInfo: '')} ($reason)');
    }
  }

  Future<void> _handleWebResourceError(WebResourceError error) async {
    if (!mounted || _leaving) return;
    // WKWebView uses -999 when a navigation is replaced or cancelled.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        error.errorCode == -999) {
      return;
    }

    var deviceOffline = false;
    final isAmbiguousHostLookup =
        error.errorType == WebResourceErrorType.hostLookup ||
            const {-2, -1003, -1006}.contains(error.errorCode);
    if (isAmbiguousHostLookup) {
      try {
        deviceOffline = await _isDeviceOffline();
      } catch (_) {
        // Fall back to the WebView's error classification.
      }
    }
    if (!mounted || _leaving) return;

    _reportResourceFailure(error.url, error.description);
    final failure = WebsiteLoadError.fromResource(
      error,
      deviceOffline: deviceOffline,
    );
    final expectedUrl = _pendingChangedUrl ?? _browser.state.url;
    final failedExpectedDocument = error.url != null &&
        WebsiteNavigationPolicy.sameDocument(error.url!, expectedUrl);
    // Some Android WebView releases incorrectly report a failed top-level
    // navigation as a subresource. The exact requested document is safe to
    // treat as main-frame even when the platform flag is false.
    final isPendingOfflineFailure =
        _pendingChangedUrl != null && failure.kind == WebsiteErrorKind.offline;
    final isMainFrame = error.isForMainFrame != false ||
        failedExpectedDocument ||
        isPendingOfflineFailure;
    if (_pendingChangedUrl != null && isMainFrame) {
      _pendingChangedUrlHadError = true;
      _changedUrlConfirmationTimer?.cancel();
    }
    if (_restoringPrevious && isMainFrame) {
      _restoreRevealTimer?.cancel();
      setState(() => _restoringPrevious = false);
    }
    _browser.failed(
      failure.message,
      title: failure.title,
      kind: failure.kind,
      url: error.url,
      isMainFrame: isMainFrame,
      preserveLoadedPage: false,
      allowOfflineRecovery: _pendingChangedUrl == null,
    );
  }

  Future<bool> _isDeviceOffline() async {
    try {
      final connectivity = await _connectivity.checkConnectivity();
      return connectivity.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<void> _handlePageFinished(String url) async {
    if (!mounted || _leaving) return;
    if (await _isNativeOfflineDocument()) {
      if (!mounted || _leaving) return;
      _changedUrlConfirmationTimer?.cancel();
      _restoreRevealTimer?.cancel();
      if (_restoringPrevious) {
        setState(() => _restoringPrevious = false);
      }
      _browser.failed(
        WebsiteLoadError.offline.message,
        title: WebsiteLoadError.offline.title,
        kind: WebsiteLoadError.offline.kind,
        url: _browser.state.url,
        isMainFrame: true,
        preserveLoadedPage: false,
        allowOfflineRecovery: false,
      );
      return;
    }
    if (await _isHostNotFoundDocument()) {
      if (!mounted || _leaving) return;
      _pendingChangedUrlHadError = _pendingChangedUrl != null;
      _changedUrlConfirmationTimer?.cancel();
      _restoreRevealTimer?.cancel();
      if (_restoringPrevious) {
        setState(() => _restoringPrevious = false);
      }
      _browser.failed(
        'Check the spelling of the website address. If it is correct, the website or DNS service may be unavailable.',
        title: 'Website address not found',
        kind: WebsiteErrorKind.address,
        url: url,
        isMainFrame: true,
        preserveLoadedPage: false,
        allowOfflineRecovery: false,
      );
      return;
    }

    _browser.finished(url);
    if (_browser.state.status != WebsiteBrowserStatus.ready) return;
    _scheduleRestoreReveal();
    _scheduleChangedUrlConfirmation();
    unawaited(_loadPageBackgroundColor(url));
    _loadWebsiteIdentity();
    _scheduleMenuTip();
  }

  Future<bool> _isHostNotFoundDocument() async {
    final controller = _controller;
    if (controller == null) return false;
    try {
      return await WebsitePageInspector.isHostNotFoundDocument(controller);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isNativeOfflineDocument() async {
    final controller = _controller;
    if (controller == null) return false;
    try {
      return await WebsitePageInspector.isNativeOfflineDocument(controller);
    } catch (_) {
      // If the page cannot be inspected, retain the existing WebView error.
      return _browser.state.status == WebsiteBrowserStatus.error &&
          _browser.state.errorKind == WebsiteErrorKind.offline;
    }
  }

  Future<void> _stopLoading(WebViewController controller) async {
    try {
      await controller
          .runJavaScript('window.stop();')
          .timeout(const Duration(seconds: 1));
    } catch (_) {
      // The platform view may already have been removed during teardown.
    }
  }

  void _scheduleChangedUrlConfirmation() {
    final pendingUrl = _pendingChangedUrl;
    if (pendingUrl == null || _pendingChangedUrlHadError) return;
    _changedUrlConfirmationTimer?.cancel();
    _changedUrlConfirmationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted ||
          _leaving ||
          _pendingChangedUrl != pendingUrl ||
          _pendingChangedUrlHadError ||
          _browser.state.status != WebsiteBrowserStatus.ready) {
        return;
      }
      setState(() {
        _pendingChangedUrl = null;
        _previousUrl = null;
        _canReturnToPreviousPage = false;
      });
      unawaited(
        context.read<WebsiteMenuCubit>().confirmChangedUrlLoaded(),
      );
    });
  }

  void _scheduleRestoreReveal() {
    if (!_restoringPrevious) return;
    _restoreRevealTimer?.cancel();
    _restoreRevealTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted ||
          _leaving ||
          _browser.state.status != WebsiteBrowserStatus.ready) {
        return;
      }
      setState(() => _restoringPrevious = false);
    });
  }

  Future<void> _close() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    final controller = _controller;
    if (controller != null) await _stopLoading(controller);
    if (mounted) context.goNamed(WebsiteRoutes.entryName);
  }

  Future<void> _back() async {
    if (_navigatingBack) return;
    _navigatingBack = true;
    try {
      final controller = _controller;
      if (controller != null && await controller.canGoBack()) {
        if (!mounted) return;
        await controller.goBack();
      } else if (mounted) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await SystemNavigator.pop();
        } else {
          await _close();
        }
      }
    } catch (_) {
      _notice(
          'Could not go back. Swipe from the right edge to open the website menu.');
    } finally {
      _navigatingBack = false;
    }
  }

  Future<void> _retry() async {
    final controller = _controller;
    if (controller == null) {
      await _initialize();
      return;
    }
    final url = _pendingChangedUrl ?? _browser.state.url;
    final recoveringFromError =
        _browser.state.status == WebsiteBrowserStatus.error;
    if (_pendingChangedUrl != null) {
      _pendingChangedUrlHadError = false;
      _changedUrlConfirmationTimer?.cancel();
    }
    _browser.started(
      url,
      resetLoadedPage: _pendingChangedUrl != null || recoveringFromError,
      intent: _pendingChangedUrl != null
          ? WebsiteLoadingIntent.changing
          : WebsiteLoadingIntent.retrying,
    );
    if (_pendingChangedUrl != null && await _isDeviceOffline()) {
      if (!mounted || _leaving) return;
      _pendingChangedUrlHadError = true;
      _browser.failed(
        WebsiteLoadError.offline.message,
        title: WebsiteLoadError.offline.title,
        kind: WebsiteLoadError.offline.kind,
        url: url,
        isMainFrame: true,
        preserveLoadedPage: false,
        allowOfflineRecovery: false,
      );
      return;
    }
    try {
      // Android can treat another loadRequest for the same failed URL as the
      // existing navigation. Force a native reload when it is already current.
      final currentUrl = await controller.currentUrl();
      if (currentUrl != null &&
          WebsiteNavigationPolicy.sameDocument(currentUrl, url)) {
        await controller.reload();
      } else {
        // Preserve the failed destination instead of returning to the launch URL.
        await controller.loadRequest(Uri.parse(url));
      }
    } catch (_) {
      _browser.failed('Could not reload this website. Please try again.');
    }
  }

  Future<void> _loadWebsiteIdentity() async {
    final controller = _controller;
    if (controller == null) return;
    final requestedUrl = _browser.state.url;
    final pageUri = Uri.tryParse(requestedUrl);
    if (pageUri == null) return;
    try {
      final identity = await WebsitePageInspector.identity(controller, pageUri);
      if (!mounted ||
          !WebsiteNavigationPolicy.sameDocument(
            requestedUrl,
            _browser.state.url,
          )) {
        return;
      }
      if (identity == null) return;
      _browser.identityChanged(
        name: identity.name,
        logoUrls: identity.logoUrls,
      );
    } catch (_) {
      // Missing metadata must never prevent navigation or opening the menu.
    }
  }

  Future<void> _loadPageBackgroundColor(String loadedUrl) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final color = await WebsitePageInspector.backgroundColor(controller);
      if (!mounted ||
          _leaving ||
          color == null ||
          !WebsiteNavigationPolicy.sameDocument(
            loadedUrl,
            _browser.state.url,
          )) {
        return;
      }
      setState(() => _pageBackgroundColor = color);
    } catch (_) {
      // Retain the cream fallback when the page cannot provide a color.
    }
  }

  Future<void> _showMenu() async {
    if (_menuOpen || !mounted) return;
    _menuOpen = true;
    context.read<WebsiteMenuTipCubit>().dismiss();
    final menu = context.read<WebsiteMenuCubit>();
    try {
      final action = await showModalBottomSheet<WebsiteMenuAction>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: style.scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
        ),
        builder: (_) => WebsiteBrowserMenu(
          cubit: menu,
          url: _browser.state.url,
          websiteName: _browser.state.websiteName,
          logoUrls: _browser.state.websiteLogoUrls,
        ),
      );
      if (!mounted) return;
      switch (action) {
        case WebsiteMenuAction.reload:
          await _retry();
          break;
        case WebsiteMenuAction.changeUrl:
          await _showChangeUrl();
          break;
        case WebsiteMenuAction.reset:
          _close();
          break;
        case null:
          // If dismissed while persistence was pending, still finish the reset.
          if (menu.state == WebsiteMenuState.resetting) {
            final state = await menu.stream
                .firstWhere((state) => state != WebsiteMenuState.resetting);
            if (!mounted) return;
            if (state == WebsiteMenuState.reset) {
              _close();
            } else {
              _notice('Could not clear the saved URL. Please try again.');
            }
          }
          break;
      }
    } finally {
      _menuOpen = false;
    }
  }

  Future<void> _showChangeUrl() async {
    if (!mounted) return;
    final address = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WebsiteChangeUrlScreen(
          currentUrl: _browser.state.url,
          cubit: context.read<WebsiteMenuCubit>(),
          websiteName: _browser.state.websiteName,
          logoUrls: _browser.state.websiteLogoUrls,
          rollbackUrl: _previousUrl,
        ),
      ),
    );
    if (!mounted || address == null) return;
    final previousUrl = _previousUrl ?? _browser.state.url;
    if (address != previousUrl) {
      setState(() {
        _previousUrl = previousUrl;
        _pendingChangedUrl = address;
        _trustedUrl = address;
        _canReturnToPreviousPage = true;
        _pendingChangedUrlHadError = false;
      });
      _changedUrlConfirmationTimer?.cancel();
    }
    _browser.started(
      address,
      resetLoadedPage: true,
      intent: WebsiteLoadingIntent.changing,
    );
    if (await _isDeviceOffline()) {
      if (!mounted || _leaving) return;
      _pendingChangedUrlHadError = true;
      _browser.failed(
        WebsiteLoadError.offline.message,
        title: WebsiteLoadError.offline.title,
        kind: WebsiteLoadError.offline.kind,
        url: address,
        isMainFrame: true,
        preserveLoadedPage: false,
      );
      return;
    }
    try {
      await _controller?.loadRequest(Uri.parse(address));
    } catch (_) {
      _browser.failed(
        'Your new address was saved, but it could not be opened. Please try reloading.',
      );
    }
  }

  Future<void> _changeUrlWhileLoading() async {
    final controller = _controller;
    if (controller != null) await _stopLoading(controller);
    if (!mounted) return;
    _browser.failed(
      'Website loading was cancelled. Retry or choose another address.',
      title: 'Loading cancelled',
    );
    await _showChangeUrl();
  }

  Future<void> _restorePreviousUrl() async {
    final previousUrl = _previousUrl;
    if (_restoringPrevious || previousUrl == null || !mounted) return;
    _restoreRevealTimer?.cancel();
    setState(() => _restoringPrevious = true);
    final result =
        await context.read<WebsiteMenuCubit>().restorePreviousUrl(previousUrl);
    if (!mounted) return;
    if (!result.succeeded) {
      setState(() => _restoringPrevious = false);
      _notice(result.error ?? 'Could not restore the previous website.');
      return;
    }
    _previousUrl = null;
    _pendingChangedUrl = null;
    _pendingChangedUrlHadError = false;
    _changedUrlConfirmationTimer?.cancel();
    _trustedUrl = previousUrl;
    _browser.started(
      previousUrl,
      resetLoadedPage: true,
      intent: WebsiteLoadingIntent.restoring,
    );
    try {
      final controller = _controller;
      if (controller != null && await controller.canGoBack()) {
        await controller.goBack();
      } else {
        await controller?.loadRequest(Uri.parse(previousUrl));
      }
      if (mounted) setState(() => _canReturnToPreviousPage = false);
    } catch (_) {
      if (mounted) setState(() => _restoringPrevious = false);
      _browser.failed(
        'The previous website was restored but could not be opened. Please try reloading.',
      );
    }
  }

  Future<void> _openExternal(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _notice('No application is available to open this link.');
      }
    } catch (_) {
      _notice('Could not open this link. Please try again.');
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    showNeoToast(context, context.tr(message));
  }

  @override
  void dispose() {
    _leaving = true;
    _menuTipTimer?.cancel();
    _changedUrlConfirmationTimer?.cancel();
    _restoreRevealTimer?.cancel();
    final controller = _controller;
    if (controller != null) unawaited(_stopLoading(controller));
    _browser.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebsiteBrowserCubit, WebsiteBrowserState>(
      bloc: _browser,
      builder: (context, state) => WebsiteBrowserView(
        state: state,
        controller: _controller,
        pageBackgroundColor: _pageBackgroundColor,
        supported: _supported,
        restoringPrevious: _restoringPrevious,
        canReturnToPreviousPage: _canReturnToPreviousPage,
        previousUrl: _previousUrl,
        onBack: _back,
        onRetry: _retry,
        onChangeAddress: _close,
        onChangeWhileLoading: _changeUrlWhileLoading,
        onRestorePrevious: _restorePreviousUrl,
        onDismissWarning: _browser.dismissResourceWarning,
        onOpenMenu: _showMenu,
        onOpenExternal: _openExternal,
      ),
    );
  }
}
