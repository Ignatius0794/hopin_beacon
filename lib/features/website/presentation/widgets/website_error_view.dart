import 'package:qbyt/features/website/presentation/helpers/website_load_error.dart';
import 'package:flutter/material.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/core/widgets/neo_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WebsiteErrorView extends StatelessWidget {
  const WebsiteErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onChangeAddress,
    this.onRestorePrevious,
    this.previousUrl,
    this.restoringPrevious = false,
    this.openExternally = false,
    this.title,
    this.kind = WebsiteErrorKind.general,
  });

  final String message;
  final String? title;
  final WebsiteErrorKind kind;
  final VoidCallback onRetry;
  final VoidCallback onChangeAddress;
  final VoidCallback? onRestorePrevious;
  final String? previousUrl;
  final bool restoringPrevious;
  final bool openExternally;

  @override
  Widget build(BuildContext context) {
    final previousHost = Uri.tryParse(previousUrl ?? '')?.host;
    return Container(
      color: style.scaffoldBackgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                openExternally
                    ? Icons.open_in_browser_rounded
                    : switch (kind) {
                        WebsiteErrorKind.address => Icons.link_off_rounded,
                        WebsiteErrorKind.offline => Icons.wifi_off_rounded,
                        WebsiteErrorKind.connection =>
                          Icons.signal_wifi_connected_no_internet_4,
                        WebsiteErrorKind.timeout =>
                          Icons.hourglass_empty_rounded,
                        WebsiteErrorKind.security => Icons.lock_outline_rounded,
                        WebsiteErrorKind.server => Icons.dns_outlined,
                        WebsiteErrorKind.general => Icons.public_off_rounded,
                      },
                size: 56,
                color: Colors.black54,
              ),
              const SizedBox(height: 16),
              if (title != null) ...[
                Text(title!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: style.appTextColor,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: style.appTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (onRestorePrevious != null) ...[
                const SizedBox(height: 10),
                Text(
                  context.tr(
                    'The new address was saved but could not be opened.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              NeoButton(
                label: context.tr(openExternally
                    ? 'Open in browser'
                    : onRestorePrevious == null
                        ? 'Retry'
                        : 'Retry new website'),
                icon: openExternally
                    ? Icons.open_in_browser_rounded
                    : Icons.refresh_rounded,
                expand: true,
                onPressed: restoringPrevious ? null : onRetry,
              ),
              if (onRestorePrevious != null) ...[
                const SizedBox(height: 16),
                _RestoreWebsiteButton(
                  domain: previousHost,
                  busy: restoringPrevious,
                  onPressed: restoringPrevious ? null : onRestorePrevious,
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: restoringPrevious ? null : onChangeAddress,
                child: Text(context.tr(onRestorePrevious == null
                    ? 'Change website URL'
                    : 'Try a different URL')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestoreWebsiteButton extends StatelessWidget {
  const _RestoreWebsiteButton({
    required this.domain,
    required this.busy,
    required this.onPressed,
  });

  final String? domain;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.55 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: const Offset(4, 4),
              child: const ColoredBox(color: Colors.black),
            ),
          ),
          Material(
            color: style.accentColor,
            child: InkWell(
              onTap: onPressed,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (busy) ...[
                      LoadingAnimationWidget.flickr(
                        leftDotColor: style.appColor,
                        rightDotColor: style.scaffoldBackgroundColor,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: busy
                          ? Text(
                              context.tr('Restoring previous website…'),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: style.scaffoldBackgroundColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr('Back to previous website'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: style.scaffoldBackgroundColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                if (domain != null && domain!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    domain!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: style.scaffoldBackgroundColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
