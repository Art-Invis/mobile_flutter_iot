import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  const SensorChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(painter: ChartPainter()),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.4,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    // Додаємо легке світіння під лінією
    final shadowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final shadowPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
