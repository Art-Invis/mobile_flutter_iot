import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';

class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isEditable;

  const MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isEditable = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              if (isEditable) ...[
                const SizedBox(width: 4),
                const Icon(Icons.edit, color: Colors.white24, size: 12),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
