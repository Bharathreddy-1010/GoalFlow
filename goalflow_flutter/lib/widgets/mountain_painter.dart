import 'package:flutter/material.dart';

class MountainIllustration extends StatelessWidget {
  final double height;

  const MountainIllustration({super.key, this.height = 320});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: MountainPainter(),
      ),
    );
  }
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Warm Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.6),
        radius: 0.9,
        colors: [
          const Color(0xFFF9EED9).withOpacity(0.9),
          const Color(0xFFF6F5F1).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(Offset(w * 0.65, h * 0.25), w * 0.45, glowPaint);

    // Soft Distant Hills (Background layer)
    final backHillPath = Path()
      ..moveTo(0, h * 0.75)
      ..quadraticBezierTo(w * 0.2, h * 0.45, w * 0.55, h * 0.48)
      ..quadraticBezierTo(w * 0.85, h * 0.52, w, h * 0.7)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final backHillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC7D3C5), Color(0xFFE4E9E2)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.55));
    canvas.drawPath(backHillPath, backHillPaint);

    // Main Lush Green Mountain (Middle layer)
    final mountainPath = Path()
      ..moveTo(0, h * 0.9)
      ..quadraticBezierTo(w * 0.15, h * 0.55, w * 0.45, h * 0.28)
      ..quadraticBezierTo(w * 0.65, h * 0.22, w * 0.7, h * 0.26)
      ..quadraticBezierTo(w * 0.85, h * 0.45, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final mountainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6B9474),
          Color(0xFF4A7253),
          Color(0xFF32533B),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.2, w, h * 0.8));
    canvas.drawPath(mountainPath, mountainPaint);

    // Mountain Right Side Shading (3D Depth)
    final shadowPath = Path()
      ..moveTo(w * 0.68, h * 0.24)
      ..quadraticBezierTo(w * 0.75, h * 0.45, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(w * 0.55, h)
      ..quadraticBezierTo(w * 0.58, h * 0.6, w * 0.68, h * 0.24)
      ..close();

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF1E3825).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(w * 0.55, h * 0.24, w * 0.45, h * 0.76));
    canvas.drawPath(shadowPath, shadowPaint);

    // Winding Beige Path (S-Curve Road to Summit)
    final roadPath = Path();
    roadPath.moveTo(w * 0.25, h * 0.98);
    roadPath.cubicTo(
      w * 0.45, h * 0.85,
      w * 0.15, h * 0.68,
      w * 0.42, h * 0.52,
    );
    roadPath.cubicTo(
      w * 0.62, h * 0.42,
      w * 0.55, h * 0.32,
      w * 0.66, h * 0.25,
    );

    // Road Outer Border / Base
    final roadBasePaint = Paint()
      ..color = const Color(0xFFCDBFA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, roadBasePaint);

    // Road Inner Sandy Surface
    final roadPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF9F1E2), Color(0xFFECDCC4)],
      ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.75))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(roadPath, roadPaint);

    // Flagpole at Summit
    final polePaint = Paint()
      ..color = const Color(0xFF9E855C)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.66, h * 0.25),
      Offset(w * 0.66, h * 0.14),
      polePaint,
    );

    // Golden Flag Wave
    final flagPath = Path()
      ..moveTo(w * 0.66, h * 0.14)
      ..quadraticBezierTo(w * 0.74, h * 0.12, w * 0.78, h * 0.16)
      ..quadraticBezierTo(w * 0.73, h * 0.21, w * 0.66, h * 0.19)
      ..close();

    final flagPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD56B), Color(0xFFE5A728)],
      ).createShader(Rect.fromLTWH(w * 0.66, h * 0.12, w * 0.15, h * 0.1));
    canvas.drawPath(flagPath, flagPaint);

    // Golden Star Sparkle near summit
    final starPaint = Paint()
      ..color = const Color(0xFFFFD875)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.82, h * 0.12), 4, starPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.08), 2.5, starPaint);

    // Soft Floating Foreground Clouds
    _drawCloud(canvas, Offset(w * 0.88, h * 0.35), 42);
    _drawCloud(canvas, Offset(w * 0.1, h * 0.48), 34);
  }

  void _drawCloud(Canvas canvas, Offset center, double radius) {
    final cloudPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(center, radius, cloudPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.6, center.dy + radius * 0.1), radius * 0.75, cloudPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.6, center.dy + radius * 0.15), radius * 0.7, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
