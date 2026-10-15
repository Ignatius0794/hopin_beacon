import 'package:flutter/material.dart';

import 'package:qbyt/core/theme/constants/styles.dart' as style;

class GridBackgroundPainter extends CustomPainter {
  final Color backgroundColor;
  final Color lineColor;
  final double gridSize;
  final double strokeWidth;

  GridBackgroundPainter({
    this.backgroundColor = style.scaffoldBackgroundColor,
    this.lineColor = style.gridLineColor,
    this.gridSize = 48.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
