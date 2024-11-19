import 'package:flutter/material.dart';

class PolylinePainter extends CustomPainter {
  final List<Offset> polylinePoints;
  final double scaleX;
  final double scaleY;

  PolylinePainter(this.polylinePoints, {required this.scaleX, required this.scaleY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw the polyline by connecting the points
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      final scaledPoint = Offset(polylinePoints[i].dx * scaleX, polylinePoints[i].dy * scaleY);
      final scaledNextPoint = Offset(polylinePoints[i + 1].dx * scaleX, polylinePoints[i + 1].dy * scaleY);
      // Draw a small circle for each node
      canvas.drawCircle(scaledPoint, 3.0, paint);
      // Draw the line between each point
      canvas.drawLine(scaledPoint, scaledNextPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Only repaint if points change
  }
}


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
