import 'package:flutter/material.dart';

class TechNode extends StatelessWidget {
  final String label;
  final Widget child;
  final Color accentColor;

  const TechNode({
    required this.label,
    required this.child,
    required this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: accentColor.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ],
    );
  }
}
