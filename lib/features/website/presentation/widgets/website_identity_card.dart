import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';

enum _CopyFeedback { idle, success, failure }

class WebsiteIdentityCard extends StatefulWidget {
  const WebsiteIdentityCard({
    super.key,
    required this.url,
    this.websiteName,
    this.logoUrls = const [],
    this.allowCopy = false,
  });

  final String url;
  final String? websiteName;
  final List<String> logoUrls;
  final bool allowCopy;

  @override
  State<WebsiteIdentityCard> createState() => _WebsiteIdentityCardState();
}

class _WebsiteIdentityCardState extends State<WebsiteIdentityCard> {
  int _logoIndex = 0;
  _CopyFeedback _copyFeedback = _CopyFeedback.idle;
  Timer? _copyResetTimer;

  @override
  void didUpdateWidget(covariant WebsiteIdentityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoUrls != widget.logoUrls) _logoIndex = 0;
    if (oldWidget.url != widget.url) {
      _copyResetTimer?.cancel();
      _copyFeedback = _CopyFeedback.idle;
    }
  }

  Future<void> _copy() async {
    _copyResetTimer?.cancel();
    setState(() => _copyFeedback = _CopyFeedback.success);
    _scheduleCopyReset();
    try {
      await Clipboard.setData(ClipboardData(text: widget.url));
    } catch (_) {
      if (!mounted) return;
      _copyResetTimer?.cancel();
      setState(() => _copyFeedback = _CopyFeedback.failure);
      _scheduleCopyReset(duration: const Duration(seconds: 2));
    }
  }

  void _scheduleCopyReset({
    Duration duration = const Duration(milliseconds: 1600),
  }) {
    _copyResetTimer = Timer(duration, () {
      if (mounted) setState(() => _copyFeedback = _CopyFeedback.idle);
    });
  }

  String _copyTooltip(BuildContext context) => context.tr(
        switch (_copyFeedback) {
          _CopyFeedback.idle => 'Copy current URL',
          _CopyFeedback.success => 'Copied',
          _CopyFeedback.failure => 'Could not copy URL',
        },
      );

  Widget _copyIcon() {
    final status = switch (_copyFeedback) {
      _CopyFeedback.idle => null,
      _CopyFeedback.success => (Icons.check_rounded, style.successColor),
      _CopyFeedback.failure => (Icons.close_rounded, style.errorColor),
    };
    return SizedBox(
      key: ValueKey(_copyFeedback),
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(child: Icon(Icons.copy_rounded, size: 23)),
          if (status != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: status.$2,
                  border: Border.all(color: Colors.white, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(status.$1, size: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.websiteName ??
        Uri.tryParse(widget.url)?.host ??
        context.tr('Website');
    final logoUrl = _logoIndex < widget.logoUrls.length
        ? widget.logoUrls[_logoIndex]
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(3, 3)),
            ],
          ),
          child: logoUrl == null
              ? const Icon(Icons.language, color: style.appColor, size: 30)
              : Image.network(
                  logoUrl,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) {
                    if (_logoIndex + 1 < widget.logoUrls.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _logoIndex++);
                      });
                    }
                    return const Icon(
                      Icons.language,
                      color: style.appColor,
                      size: 30,
                    );
                  },
                ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: SizedBox(
            height: 56,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: displayName,
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: style.appTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Tooltip(
                    message: widget.url,
                    child: Text(
                      widget.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.allowCopy) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: _copyTooltip(context),
            onPressed: _copy,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: _copyIcon(),
            ),
            color: style.appColor,
          ),
        ],
      ],
    );
  }
}
