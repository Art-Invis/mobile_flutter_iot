import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';

class ControlTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isOn;
  final VoidCallback onTap;

  const ControlTile({
    required this.title,
    required this.icon,
    required this.isOn,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          children: [
            Icon(
              icon,
              color: isOn ? const Color(0xFF38BDF8) : Colors.white24,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              isOn ? 'ON' : 'OFF',
              style: TextStyle(
                color: isOn ? const Color(0xFF4ADE80) : Colors.white24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
