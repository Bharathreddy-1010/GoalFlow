import 'package:flutter/material.dart';

class PlantIllustration extends StatelessWidget {
  final double size;

  const PlantIllustration({super.key, this.size = 85});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PlantPainter(),
      ),
    );
  }
}

class PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ceramic Pot Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x15000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.85, w * 0.6, h * 0.12), shadowPaint);

    // Ceramic Pot Base
    final potPath = Path()
      ..moveTo(w * 0.28, h * 0.62)
      ..lineTo(w * 0.35, h * 0.9)
      ..quadraticBezierTo(w * 0.5, h * 0.94, w * 0.65, h * 0.9)
      ..lineTo(w * 0.72, h * 0.62)
      ..close();

    final potPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF0EDE6), Color(0xFFDED8CD)],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.6, w * 0.5, h * 0.35));
    canvas.drawPath(potPath, potPaint);

    // Ceramic Pot Rim
    final rimRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.48, height: h * 0.08);
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFAF7F0), Color(0xFFD5CEBF)],
      ).createShader(rimRect);
    canvas.drawOval(rimRect, rimPaint);

    // Soil
    final soilRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.42, height: h * 0.05);
    final soilPaint = Paint()..color = const Color(0xFF6B5845);
    canvas.drawOval(soilRect, soilPaint);

    // Plant Main Stem
    final stemPath = Path()
      ..moveTo(w * 0.5, h * 0.62)
      ..quadraticBezierTo(w * 0.48, h * 0.45, w * 0.5, h * 0.28);
    final stemPaint = Paint()
      ..color = const Color(0xFF4C7B58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stemPath, stemPaint);

    // Left Leaf (Curved smooth 3D leaf)
    final leftLeafPath = Path()
      ..moveTo(w * 0.49, h * 0.48)
      ..cubicTo(w * 0.3, h * 0.46, w * 0.18, h * 0.32, w * 0.24, h * 0.22)
      ..cubicTo(w * 0.38, h * 0.26, w * 0.46, h * 0.36, w * 0.49, h * 0.48)
      ..close();

    final leftLeafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF7CB88B), Color(0xFF437651)],
      ).createShader(Rect.fromLTWH(w * 0.18, h * 0.22, w * 0.32, h * 0.28));
    canvas.drawPath(leftLeafPath, leftLeafPaint);

    // Right Leaf
    final rightLeafPath = Path()
      ..moveTo(w * 0.5, h * 0.4)
      ..cubicTo(w * 0.68, h * 0.38, w * 0.82, h * 0.26, w * 0.78, h * 0.16)
      ..cubicTo(w * 0.62, h * 0.18, w * 0.54, h * 0.28, w * 0.5, h * 0.4)
      ..close();

    final rightLeafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF88C897), Color(0xFF487F56)],
      ).createShader(Rect.fromLTWH(w * 0.5, h * 0.16, w * 0.32, h * 0.26));
    canvas.drawPath(rightLeafPath, rightLeafPaint);

    // Top Bud Leaf
    final topLeafPath = Path()
      ..moveTo(w * 0.5, h * 0.28)
      ..cubicTo(w * 0.42, h * 0.18, w * 0.46, h * 0.08, w * 0.52, h * 0.06)
      ..cubicTo(w * 0.58, h * 0.12, w * 0.56, h * 0.22, w * 0.5, h * 0.28)
      ..close();

    final topLeafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFA2DEB0), Color(0xFF558F64)],
      ).createShader(Rect.fromLTWH(w * 0.42, h * 0.06, w * 0.16, h * 0.24));
    canvas.drawPath(topLeafPath, topLeafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
