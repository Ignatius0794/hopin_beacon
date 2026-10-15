import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/core/widgets/neo_button.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart';
import 'package:qbyt/features/website/presentation/widgets/website_identity_card.dart';

enum WebsiteMenuAction { reload, changeUrl, reset }

class WebsiteBrowserMenu extends StatelessWidget {
  const WebsiteBrowserMenu(
      {super.key,
      required this.cubit,
      required this.url,
      this.websiteName,
      this.logoUrls = const []});
  final WebsiteMenuCubit cubit;
  final String url;
  final String? websiteName;
  final List<String> logoUrls;

  Future<void> _confirmForget(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _ForgetWebsiteDialog(
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (confirmed == true) cubit.resetUrl();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WebsiteMenuCubit, WebsiteMenuState>(
      bloc: cubit,
      listener: (context, state) {
        if (state == WebsiteMenuState.reset) {
          Navigator.of(context).pop(WebsiteMenuAction.reset);
        }
      },
      builder: (context, state) {
        final busy = state == WebsiteMenuState.resetting;
        return PopScope(
          canPop: !busy,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                      child:
                          Container(width: 40, height: 4, color: Colors.black)),
                  const SizedBox(height: 20),
                  WebsiteIdentityCard(
                    url: url,
                    websiteName: websiteName,
                    logoUrls: logoUrls,
                    allowCopy: true,
                  ),
                  const SizedBox(height: 25),
                  _MenuActionCard(
                    enabled: !busy,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    title: context.tr('Reload page'),
                    subtitle: context.tr('Refresh the current website'),
                    onTap: () =>
                        Navigator.of(context).pop(WebsiteMenuAction.reload),
                  ),
                  const SizedBox(height: 16),
                  _MenuActionCard(
                    enabled: !busy,
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    title: context.tr('Change URL'),
                    subtitle: context.tr('Edit your saved website address'),
                    onTap: () =>
                        Navigator.of(context).pop(WebsiteMenuAction.changeUrl),
                  ),
                  const SizedBox(height: 16),
                  _MenuActionCard(
                    enabled: !busy,
                    icon: busy
                        ? LoadingAnimationWidget.flickr(
                            leftDotColor: Colors.white,
                            rightDotColor: style.scaffoldBackgroundColor,
                            size: 28,
                          )
                        : const Icon(Icons.home_outlined, color: Colors.white),
                    title: context.tr(
                      busy ? 'Forgetting…' : 'Forget website',
                    ),
                    subtitle: context.tr(
                      'Remove the saved URL and return to setup',
                    ),
                    showArrow: !busy,
                    onTap: () => _confirmForget(context),
                  ),
                  if (state == WebsiteMenuState.error)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        context.tr(
                          'Could not clear the saved URL. Please try again.',
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: style.errorColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForgetWebsiteDialog extends StatelessWidget {
  const _ForgetWebsiteDialog({
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Transform.translate(
                offset: const Offset(5, 5),
                child: const ColoredBox(color: Colors.black),
              ),
            ),
            Material(
              color: style.scaffoldBackgroundColor,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: style.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.tr('Forget this website?'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: style.appTextColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(
                        'QBYT will remove the saved URL and return to setup. You can connect it again later.',
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: style.appTextColor,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    NeoButton(
                      label: context.tr('Forget website'),
                      icon: Icons.delete_outline_rounded,
                      onPressed: onConfirm,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: style.appTextColor,
                      ),
                      child: Text(context.tr('Cancel')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuActionCard extends StatelessWidget {
  const _MenuActionCard({
    required this.enabled,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  final bool enabled;
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = enabled ? style.appTextColor : Colors.black38;
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$title. $subtitle.',
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
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
              color: style.appOffColor,
              child: InkWell(
                onTap: enabled ? onTap : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: style.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: icon,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: enabled ? Colors.black : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showArrow)
                        Icon(Icons.arrow_forward_rounded, color: foreground),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
