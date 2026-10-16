import 'package:flutter/material.dart';

import 'package:sandbox/core/theme/constants/styles.dart' as style;

class GridBackgroundPainter extends CustomPainter {
  GridBackgroundPainter({
    this.backgroundColor = style.scaffoldBackgroundColor,
    this.lineColor = style.gridLineColor,
    this.gridSize = 48,
    this.strokeWidth = 1,
  });

  final Color backgroundColor;
  final Color lineColor;
  final double gridSize;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = backgroundColor,
    );

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridSize != gridSize ||
      oldDelegate.strokeWidth != strokeWidth;
}
