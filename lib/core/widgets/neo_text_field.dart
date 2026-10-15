import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qbyt/features/website/presentation/i18n/app_localizations.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;

class NeoTextField extends StatelessWidget {
  const NeoTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.helperText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.onPaste,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? helperText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onPaste;

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      controller.text = data.text!;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      onPaste?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final disabledColor = textColor.withValues(alpha: 0.38);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: label,
          textField: true,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autocorrect: false,
            enableSuggestions: false,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: style.accentColor,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              errorMaxLines: 3,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: style.errorColor,
                height: 2,
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              // Keep validation text aligned to the outer border; the prefix
              // supplies padding only to the editable content.
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 18,
              ),
              prefixIcon: const SizedBox(width: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 0,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  tooltip: context.tr('Paste from clipboard'),
                  icon: const Icon(Icons.content_paste_rounded),
                  color: textColor,
                  onPressed: enabled ? _handlePaste : null,
                ),
              ),
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: textColor.withValues(alpha: 0.45),
                fontWeight: FontWeight.w400,
              ),
              border: _NeoInputBorder(
                borderSide: BorderSide(color: textColor, width: 3),
                shadowColor: textColor,
              ),
              enabledBorder: _NeoInputBorder(
                borderSide: BorderSide(color: textColor, width: 3),
                shadowColor: textColor,
              ),
              focusedBorder: _NeoInputBorder(
                borderSide: const BorderSide(
                  color: style.accentColor,
                  width: 3,
                ),
                shadowColor: textColor,
              ),
              disabledBorder: _NeoInputBorder(
                borderSide: BorderSide(color: disabledColor, width: 3),
                shadowColor: disabledColor,
              ),
              errorBorder: _NeoInputBorder(
                borderSide: const BorderSide(color: style.errorColor, width: 3),
                shadowColor: textColor,
              ),
              focusedErrorBorder: _NeoInputBorder(
                borderSide: const BorderSide(color: style.errorColor, width: 3),
                shadowColor: textColor,
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 10),
          Text(
            helperText!,
            textAlign: TextAlign.start,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _NeoInputBorder extends OutlineInputBorder {
  const _NeoInputBorder({
    super.borderSide = const BorderSide(color: Colors.black, width: 3),
    this.shadowColor = Colors.black,
  }) : super(borderRadius: BorderRadius.zero);

  final Color shadowColor;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0,
    double gapPercentage = 0,
    TextDirection? textDirection,
  }) {
    final paint = Paint()..color = shadowColor;
    const offset = 4.0;
    canvas.drawRect(
      Rect.fromLTWH(rect.left + offset, rect.bottom, rect.width, offset),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        rect.right,
        rect.top + offset,
        offset,
        rect.height - offset,
      ),
      paint,
    );
    super.paint(
      canvas,
      rect,
      gapStart: gapStart,
      gapExtent: gapExtent,
      gapPercentage: gapPercentage,
      textDirection: textDirection,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => a is _NeoInputBorder
      ? _NeoInputBorder(
          borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
          shadowColor: Color.lerp(a.shadowColor, shadowColor, t)!,
        )
      : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => b is _NeoInputBorder
      ? _NeoInputBorder(
          borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
          shadowColor: Color.lerp(shadowColor, b.shadowColor, t)!,
        )
      : super.lerpTo(b, t);

  @override
  OutlineInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
  }) =>
      _NeoInputBorder(
        borderSide: borderSide ?? this.borderSide,
        shadowColor: shadowColor,
      );
}
