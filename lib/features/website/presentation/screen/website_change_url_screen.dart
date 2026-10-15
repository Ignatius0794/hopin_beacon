import 'package:flutter/material.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/presentation/misc/grid_background_painter.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/core/widgets/neo_button.dart';
import 'package:qbyt/core/widgets/neo_text_field.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart';
import 'package:qbyt/features/website/presentation/helpers/website_messages.dart';
import 'package:qbyt/features/website/presentation/widgets/website_identity_card.dart';

class WebsiteChangeUrlScreen extends StatefulWidget {
  const WebsiteChangeUrlScreen({
    super.key,
    required this.currentUrl,
    required this.cubit,
    this.websiteName,
    this.logoUrls = const [],
    this.rollbackUrl,
  });

  final String currentUrl;
  final WebsiteMenuCubit cubit;
  final String? websiteName;
  final List<String> logoUrls;
  final String? rollbackUrl;

  @override
  State<WebsiteChangeUrlScreen> createState() => _WebsiteChangeUrlScreenState();
}

class _WebsiteChangeUrlScreenState extends State<WebsiteChangeUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _saving = false;
  String? _saveError;

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final result = await widget.cubit.changeUrl(
      _urlController.text,
      previousUrl: widget.rollbackUrl ?? widget.currentUrl,
    );
    if (!mounted) return;
    if (result.succeeded) {
      Navigator.of(context).pop(result.address);
      return;
    }
    setState(() {
      _saving = false;
      _saveError = result.error;
    });
  }

  void _cancel() {
    if (!_saving) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        body: CustomPaint(
          painter: GridBackgroundPainter(
            backgroundColor: style.scaffoldBackgroundColor,
            lineColor: style.gridLineColor,
            gridSize: 48,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: context.tr('Cancel and return to website'),
                        onPressed: _saving ? null : _cancel,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          context.tr('Change URL'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: style.appTextColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.tr('Current website'),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              WebsiteIdentityCard(
                                url: widget.currentUrl,
                                websiteName: widget.websiteName,
                                logoUrls: widget.logoUrls,
                                allowCopy: true,
                              ),
                              const SizedBox(height: 25),
                              NeoTextField(
                                controller: _urlController,
                                enabled: !_saving,
                                label: context.tr('New URL'),
                                hintText: 'https://your-new-website.com',
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.go,
                                validator: (value) =>
                                    WebsiteAddress.tryParse(value ?? '') == null
                                        ? context.tr(
                                            WebsiteMessages.invalidAddress,
                                          )
                                        : null,
                                onFieldSubmitted: (_) => _submit(),
                                onPaste: () =>
                                    setState(() => _saveError = null),
                              ),
                              if (_saveError != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  context.tr(_saveError!),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: style.errorColor,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.center,
                                child: NeoButton(
                                  label: context.tr(
                                    _saving ? 'Saving…' : 'Change website',
                                  ),
                                  showArrow: !_saving,
                                  onPressed: _saving ? null : _submit,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
