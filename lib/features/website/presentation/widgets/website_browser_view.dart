import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/features/website/presentation/bloc/website_browser_cubit.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_tip_cubit.dart';
import 'package:qbyt/features/website/presentation/widgets/website_error_view.dart';
import 'package:qbyt/features/website/presentation/widgets/website_menu_edge.dart';
import 'package:qbyt/features/website/presentation/widgets/website_menu_tip.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteBrowserView extends StatelessWidget {
  const WebsiteBrowserView({
    super.key,
    required this.state,
    required this.pageBackgroundColor,
    required this.supported,
    required this.restoringPrevious,
    required this.canReturnToPreviousPage,
    required this.onBack,
    required this.onRetry,
    required this.onChangeAddress,
    required this.onChangeWhileLoading,
    required this.onRestorePrevious,
    required this.onDismissWarning,
    required this.onOpenMenu,
    required this.onOpenExternal,
    this.controller,
    this.previousUrl,
  });

  final WebsiteBrowserState state;
  final WebViewController? controller;
  final Color pageBackgroundColor;
  final bool supported;
  final bool restoringPrevious;
  final bool canReturnToPreviousPage;
  final String? previousUrl;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final VoidCallback onChangeAddress;
  final VoidCallback onChangeWhileLoading;
  final VoidCallback onRestorePrevious;
  final VoidCallback onDismissWarning;
  final VoidCallback onOpenMenu;
  final ValueChanged<Uri> onOpenExternal;

  @override
  Widget build(BuildContext context) {
    final useLightSystemIcons = pageBackgroundColor.computeLuminance() < 0.5;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: pageBackgroundColor,
          statusBarIconBrightness:
              useLightSystemIcons ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              useLightSystemIcons ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: pageBackgroundColor,
          systemNavigationBarIconBrightness:
              useLightSystemIcons ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: pageBackgroundColor,
          // Android already passes this inset through CSS env(); adding a
          // Flutter bottom SafeArea would lift fixed page bars twice.
          body: SafeArea(
            bottom: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (controller != null) WebViewWidget(controller: controller!),
                if (state.status == WebsiteBrowserStatus.error)
                  WebsiteErrorView(
                    title: state.errorTitle == null
                        ? null
                        : context.tr(state.errorTitle!),
                    kind: state.errorKind,
                    message: context.tr(
                      state.message ??
                          'Could not load this website. Please try again.',
                    ),
                    openExternally: !supported,
                    onRetry: supported
                        ? onRetry
                        : () => onOpenExternal(Uri.parse(state.url)),
                    onChangeAddress: onChangeAddress,
                    onRestorePrevious:
                        !canReturnToPreviousPage ? null : onRestorePrevious,
                    previousUrl: previousUrl,
                    restoringPrevious: restoringPrevious,
                  ),
                if (restoringPrevious ||
                    (state.status == WebsiteBrowserStatus.loading &&
                        !state.hasLoadedPage))
                  _LoadingCover(
                    intent: state.loadingIntent,
                    onCancel: switch (state.loadingIntent) {
                      WebsiteLoadingIntent.retrying ||
                      WebsiteLoadingIntent.changing =>
                        onChangeWhileLoading,
                      WebsiteLoadingIntent.opening ||
                      WebsiteLoadingIntent.restoring =>
                        onChangeAddress,
                    },
                  ),
                if (state.status == WebsiteBrowserStatus.loading &&
                    state.hasLoadedPage)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: state.progress == 0 ? null : state.progress / 100,
                    ),
                  ),
                if (state.status == WebsiteBrowserStatus.ready &&
                    state.resourceWarning != null)
                  Positioned(
                    left: 12,
                    right: 32,
                    bottom: 12,
                    child: Material(
                      color: style.scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.tr(state.resourceWarning!),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: style.appTextColor),
                              ),
                            ),
                            IconButton(
                              tooltip: context.tr('Dismiss notice'),
                              onPressed: onDismissWarning,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: BlocBuilder<WebsiteMenuTipCubit, bool>(
                    builder: (context, visible) => Stack(
                      children: [
                        if (state.status == WebsiteBrowserStatus.ready &&
                            visible)
                          Positioned(
                            right: 32,
                            left: 24,
                            top: 0,
                            bottom: 0,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: WebsiteMenuTip(
                                onDismiss:
                                    context.read<WebsiteMenuTipCubit>().dismiss,
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: WebsiteMenuEdge(
                            onOpen: onOpenMenu,
                            highlighted: visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCover extends StatelessWidget {
  const _LoadingCover({required this.intent, required this.onCancel});

  final WebsiteLoadingIntent intent;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.flickr(
                  leftDotColor: style.appColor,
                  rightDotColor: style.accentColor,
                  size: 28,
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr(switch (intent) {
                    WebsiteLoadingIntent.opening => 'Opening your website…',
                    WebsiteLoadingIntent.retrying => 'Retrying website…',
                    WebsiteLoadingIntent.changing => 'Opening new website…',
                    WebsiteLoadingIntent.restoring =>
                      'Restoring previous website…',
                  }),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: style.appTextColor),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    context.tr(switch (intent) {
                      WebsiteLoadingIntent.opening ||
                      WebsiteLoadingIntent.restoring =>
                        'Cancel and return to setup',
                      WebsiteLoadingIntent.retrying => 'Change website URL',
                      WebsiteLoadingIntent.changing => 'Try a different URL',
                    }),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: style.appColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
