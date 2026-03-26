import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';

class WorkspaceCard extends StatelessWidget {
  final String id;
  final String title;
  final String value;
  final String status;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onAnalyticsTap;

  const WorkspaceCard({
    required this.id,
    required this.title,
    required this.value,
    required this.status,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onAnalyticsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accentColor, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onAnalyticsTap ??
                    () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: SensorArguments(
                          id: id,
                          title: title,
                          value: value,
                          icon: icon,
                          color: accentColor,
                        ),
                      );
                    },
                child: Text(
                  'ANALYTICS',
                  style: TextStyle(
                    fontSize: 10,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
