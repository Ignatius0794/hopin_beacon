import 'package:flutter/material.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;

class WebsiteMenuTip extends StatelessWidget {
  const WebsiteMenuTip({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
        decoration: BoxDecoration(
          color: style.scaffoldBackgroundColor,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.swipe_left_rounded, color: style.accentColor),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(context.tr('Website controls'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: style.appTextColor,
                          fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 10),
            Text(
                context.tr(
                  'Swipe or tap the right edge to reload, change URL, or return to the menu.',
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: style.appTextColor, height: 1.5)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(foregroundColor: style.appColor),
                  child: Text(context.tr('Got it'))),
            ),
          ],
        ),
      ),
    );
  }
}
