// Віджет пульсуючого індикатора для Header
import 'package:flutter/material.dart';

class SystemPulseIndicator extends StatefulWidget {
  const SystemPulseIndicator({super.key});

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
      duration: const Duration(seconds: 2),
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
        decoration: const BoxDecoration(
          color: Color(0xFF4ADE80),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0xFF4ADE80), blurRadius: 8)],
        ),
      ),
    );
  }
}
