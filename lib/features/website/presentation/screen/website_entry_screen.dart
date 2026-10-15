import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qbyt/core/presentation/bloc/app_locale_cubit.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/presentation/bloc/website_entry_cubit.dart';
import 'package:qbyt/features/website/presentation/helpers/website_messages.dart';
import 'package:qbyt/features/website/presentation/routes/website_routes.dart';

import 'package:qbyt/core/presentation/misc/grid_background_painter.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/core/widgets/brand_badge.dart';
import 'package:qbyt/core/widgets/neo_button.dart';
import 'package:qbyt/core/widgets/neo_text_field.dart';

class WebsiteEntryScreen extends StatefulWidget {
  const WebsiteEntryScreen({super.key});

  @override
  State<WebsiteEntryScreen> createState() => _WebsiteEntryScreenState();
}

class _WebsiteEntryScreenState extends State<WebsiteEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  void _open() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<WebsiteEntryCubit>().open(_urlController.text);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WebsiteEntryCubit, WebsiteEntryState>(
      listener: (context, state) {
        if (state.status == WebsiteEntryStatus.ready) {
          _urlController.text = state.address;
        } else if (state.status == WebsiteEntryStatus.opened) {
          context.goNamed(
            WebsiteRoutes.browserName,
            extra: state.address,
          );
        }
      },
      builder: (context, state) {
        final busy = state.status == WebsiteEntryStatus.saving ||
            state.status == WebsiteEntryStatus.loading;
        return Scaffold(
          body: CustomPaint(
            painter: GridBackgroundPainter(
              backgroundColor: style.scaffoldBackgroundColor,
              lineColor: style.gridLineColor,
              gridSize: 48.0,
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const BrandBadge(animate: false),
                              const SizedBox(height: 18),
                              Text(
                                'QBYT',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                  fontFamily: style.swashFontFamily,
                                  color: style.appColor,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFeatures: const [FontFeature.swash()],
                                  shadows: const [
                                    Shadow(
                                        color: style.appColor,
                                        offset: Offset(1, 0)),
                                    Shadow(
                                        color: style.appColor,
                                        offset: Offset(-1, 0)),
                                    Shadow(
                                        color: style.appColor,
                                        offset: Offset(0, 1)),
                                    Shadow(
                                        color: style.appColor,
                                        offset: Offset(0, -1)),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: style.appTextColor
                                            .withValues(alpha: 0.6),
                                      ),
                                  children: [
                                    TextSpan(
                                        text: 'Systems your ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            )),
                                    TextSpan(
                                      text: 'own people',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            color: style.accentColor,
                                          ),
                                    ),
                                    TextSpan(
                                        text: ' can run.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            )),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              NeoTextField(
                                controller: _urlController,
                                enabled: !busy,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.go,
                                label: context.tr('Connect to your workspace'),
                                hintText: 'https://your-website.com',
                                helperText: context.tr(
                                  'Enter your web app address to get started. You only need to do this one time.',
                                ),
                                validator: (value) =>
                                    WebsiteAddress.tryParse(value ?? '') == null
                                        ? context
                                            .tr(WebsiteMessages.invalidAddress)
                                        : null,
                                onFieldSubmitted: (_) => _open(),
                              ),
                              if (state.error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  context.tr(state.error!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              NeoButton(
                                label: context.tr(
                                  busy ? 'Please wait…' : 'Continue',
                                ),
                                showArrow: !busy,
                                onPressed: busy ? null : _open,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: const _LanguageSelector(),
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

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLocaleCubit, Locale>(
      builder: (context, locale) => DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: style.appTextColor,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: style.scaffoldBackgroundColor,
            border: Border.all(color: style.appTextColor, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(
                label: 'EN',
                selected: locale.languageCode == 'en',
                onTap: () =>
                    context.read<AppLocaleCubit>().changeLanguage('en'),
              ),
              Container(width: 2, height: 36, color: style.appTextColor),
              _LanguageOption(
                label: 'BM',
                selected: locale.languageCode == 'ms',
                onTap: () =>
                    context.read<AppLocaleCubit>().changeLanguage('ms'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label == 'EN' ? 'English' : 'Bahasa Melayu',
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: selected ? style.appColor : Colors.transparent,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : style.appTextColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
          ),
        ),
      ),
    );
  }
}
