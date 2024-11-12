import 'package:flutter/material.dart';

class OutlinePainter extends CustomPainter {
  final List<Offset> outlinePoints;
  final double scaleX;
  final double scaleY;
  final Offset? tapPosition;

  OutlinePainter(this.outlinePoints, {required this.scaleX, required this.scaleY, this.tapPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final paintOrange = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw the red outline points
    for (var point in outlinePoints) {
      final scaledPoint = Offset(point.dx * scaleX, point.dy * scaleY);
      canvas.drawCircle(scaledPoint, 1.0, paintRed); // Drawing a small circle for each outline point
    }

    // Draw the orange circle if tapPosition is not null
    if (tapPosition != null) {
      final scaledTapPosition = Offset(tapPosition!.dx * scaleX, tapPosition!.dy * scaleY);
      canvas.drawCircle(scaledTapPosition, 10.0, paintOrange); // Large orange circle around the tap
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
