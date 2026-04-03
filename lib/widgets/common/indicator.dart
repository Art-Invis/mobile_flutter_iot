import 'package:flutter/material.dart';

class SystemPulseIndicator extends StatefulWidget {
  final Color color;

  const SystemPulseIndicator({
    required this.color,
    super.key,
  });

  @override
  State<SystemPulseIndicator> createState() => _SystemPulseIndicatorState();
}

class _SystemPulseIndicatorState extends State<SystemPulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
