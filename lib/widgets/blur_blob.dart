import 'package:flutter/material.dart';

class BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;
  final Offset translation;

  const BlurBlob({
    required this.color,
    required this.size,
    this.alignment = Alignment.center,
    this.translation = Offset.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionalTranslation(
        translation: translation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: size / 2,
                spreadRadius: size / 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
