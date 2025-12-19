import 'package:flutter/material.dart';
import 'dart:math' as math;

class NavigationArrowMarker extends StatelessWidget {
  final double heading;
  final double size;

  const NavigationArrowMarker({
    super.key,
    required this.heading,
    this.size = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: heading),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: angle * math.pi / 180,
          child: child,
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          size: Size(size, size),
          painter: _CircularArrowPainter(),
        ),
      ),
    );
  }
}

class _CircularArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final circleShadowPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(circleShadowPath, Colors.black.withOpacity(0.3), 3.0, true);

    final circlePaint = Paint()
      ..color = const Color(0xFFE1F5FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);
    final path = Path();
    path.moveTo(w / 2, h * 0.25); 
    path.lineTo(w * 0.75, h * 0.75); 
    path.lineTo(w / 2, h * 0.65);
    path.lineTo(w * 0.25, h * 0.75); 
    path.close();
    final gradient = const RadialGradient(
      colors: [
        Color(0xFF65A4F9),
        Color(0xFF4285F4),
      ],
      center: Alignment(0.0, -0.2),
      radius: 0.8,
    );

    final arrowPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 2.0, true);

    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
