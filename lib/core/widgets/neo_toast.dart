import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;

OverlayEntry? _activeToast;
Timer? _dismissTimer;

void _hideNeoToast() {
  _dismissTimer?.cancel();
  _dismissTimer = null;
  final toast = _activeToast;
  _activeToast = null;
  toast?.remove();
  toast?.dispose();
}

void showNeoToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final theme = Theme.of(context);
  // Unlike padding, viewPadding retains the device inset inside SafeArea.
  final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
  final closeLabel = MaterialLocalizations.of(context).closeButtonTooltip;
  _hideNeoToast();

  final toast = OverlayEntry(
    builder: (_) => Positioned(
      bottom: safeBottom + 20,
      left: 20,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(4, 4),
                  child: Container(color: style.appTextColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: style.scaffoldBackgroundColor,
                  border: Border.all(color: style.appTextColor, width: 3),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: style.appTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: style.appTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: closeLabel,
                      child: InkWell(
                        onTap: _hideNeoToast,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: style.appTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  _activeToast = toast;
  overlay.insert(toast);
  _dismissTimer = Timer(duration, _hideNeoToast);
}
