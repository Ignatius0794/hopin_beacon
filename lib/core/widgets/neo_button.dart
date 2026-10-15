import 'package:flutter/material.dart';

class NeoButton extends StatefulWidget {
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
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(_curve);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectivePressed = _isEnabled && _pressed;

    return FadeTransition(
      opacity: _curve,
      child: ScaleTransition(
        scale: _scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HardShadowPainter(offset: effectivePressed ? 0 : 4),
              ),
            ),
            GestureDetector(
              onTapDown:
                  _isEnabled ? (_) => setState(() => _pressed = true) : null,
              onTapUp:
                  _isEnabled ? (_) => setState(() => _pressed = false) : null,
              onTapCancel:
                  _isEnabled ? () => setState(() => _pressed = false) : null,
              onTap: widget.onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                transform: Matrix4.translationValues(
                  effectivePressed ? 4 : 0,
                  effectivePressed ? 4 : 0,
                  0,
                ),
                child: Container(
                  width: widget.expand ? double.infinity : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isEnabled ? Colors.transparent : Colors.black12,
                    border: Border.all(
                      color: _isEnabled ? Colors.black : Colors.black38,
                      width: 3,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        widget.expand ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      if (widget.expand)
                        Expanded(
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: _isEnabled
                                      ? Colors.black
                                      : Colors.black38,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        )
                      else
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color:
                                    _isEnabled ? Colors.black : Colors.black38,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      if (widget.showArrow || widget.icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.icon ?? Icons.arrow_forward_rounded,
                          size: 20,
                          color: _isEnabled ? Colors.black : Colors.black38,
                        ),
                      ],
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

class _HardShadowPainter extends CustomPainter {
  const _HardShadowPainter({this.offset = 4});

  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    canvas.drawRect(
      Rect.fromLTWH(offset, size.height, size.width, offset),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width, offset, offset, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HardShadowPainter oldDelegate) =>
      oldDelegate.offset != offset;
}
