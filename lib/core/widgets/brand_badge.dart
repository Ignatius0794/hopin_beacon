import 'package:flutter/material.dart';

class BrandBadge extends StatefulWidget {
  const BrandBadge({super.key, this.size = 120, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<BrandBadge> createState() => _BrandBadgeState();
}

class _BrandBadgeState extends State<BrandBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(_curve);
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      height: widget.size,
      width: widget.size,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade900,
        ),
        child: Image.asset(
          'assets/images/qbyt.png',
          fit: BoxFit.contain,
        ),
      ),
    );

    if (!widget.animate) {
      return badge;
    }

    return FadeTransition(
      opacity: _curve,
      child: ScaleTransition(
        scale: _scale,
        child: badge,
      ),
    );
  }
}
