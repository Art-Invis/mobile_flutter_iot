import 'package:flutter/material.dart';

class RotatingFan extends StatefulWidget {
  final double size;
  final Color color;

  const RotatingFan({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF38BDF8),
  });

  @override
  State<RotatingFan> createState() => _RotatingFanState();
}

class _RotatingFanState extends State<RotatingFan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.cyclone, size: widget.size, color: widget.color),
    );
  }
}
