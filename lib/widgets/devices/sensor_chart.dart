import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  final Color color;
  const SensorChart({super.key, this.color = const Color(0xFF38BDF8)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: CustomPaint(painter: ChartPainter(color: color)),
    );
  }
}

class ChartPainter extends CustomPainter {
  final Color color;
  ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.9,
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.8,
      size.width * 0.8,
      size.height * 0.1,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
