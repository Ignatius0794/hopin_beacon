import 'package:flutter/material.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;

/// A narrow, full-height right-edge gesture strip keeps the website controls
/// reachable while leaving the rest of the WebView untouched.
class WebsiteMenuEdge extends StatefulWidget {
  const WebsiteMenuEdge({
    super.key,
    required this.onOpen,
    this.highlighted = false,
  });
  final VoidCallback onOpen;
  final bool highlighted;

  @override
  State<WebsiteMenuEdge> createState() => _WebsiteMenuEdgeState();
}

class _WebsiteMenuEdgeState extends State<WebsiteMenuEdge> {
  double _distance = 0;
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inkColor = theme.colorScheme.onSurface;

    return Semantics(
      label: context.tr('Website menu'),
      hint: context.tr(
        'Swipe left from the right edge to open website controls',
      ),
      button: true,
      onTap: widget.onOpen,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpen,
        onHorizontalDragStart: (_) {
          _distance = 0;
          _opened = false;
        },
        onHorizontalDragUpdate: (details) {
          _distance -= details.delta.dx;
          if (!_opened && _distance >= 48) {
            _opened = true;
            widget.onOpen();
          }
        },
        child: SizedBox(
          width: 24,
          height: double.infinity,
          child: Center(
            child: Transform.translate(
              offset: const Offset(4, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: widget.highlighted ? 8 : 6,
                height: widget.highlighted ? 46 : 40,
                decoration: BoxDecoration(
                  color: widget.highlighted
                      ? style.accentColor
                      : inkColor.withValues(alpha: 0.28),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
