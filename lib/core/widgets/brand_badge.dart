import 'package:flutter/material.dart';

class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, this.size = 120, this.animate = true});

  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset('assets/images/qbyt.png', fit: BoxFit.contain),
    );
  }
}
