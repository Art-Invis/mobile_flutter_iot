import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';

class OverrideBackground extends StatelessWidget {
  final bool isOverrideActive;

  const OverrideBackground({required this.isOverrideActive, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorTop = isOverrideActive
        ? Colors.redAccent.withValues(alpha: 0.15)
        : const Color(0xFF38BDF8).withValues(alpha: 0.1);

    final colorBottom = isOverrideActive
        ? Colors.orange.withValues(alpha: 0.15)
        : const Color(0xFF4ADE80).withValues(alpha: 0.08);

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: BlurBlob(
            alignment: Alignment.topRight,
            translation: const Offset(0.3, -0.3),
            color: colorTop,
            size: size.width * 0.7,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: BlurBlob(
            alignment: Alignment.bottomLeft,
            translation: const Offset(-0.3, 0.3),
            color: colorBottom,
            size: size.width * 0.8,
          ),
        ),
      ],
    );
  }
}
