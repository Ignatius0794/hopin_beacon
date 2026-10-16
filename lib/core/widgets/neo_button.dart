import 'package:flutter/material.dart';

class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.showArrow = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? (showArrow ? Icons.arrow_forward : null);
    final button = effectiveIcon == null
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(effectiveIcon),
            label: Text(label),
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
