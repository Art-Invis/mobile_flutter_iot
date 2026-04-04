import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/devices/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'title': 'High CO2 Level',
        'message': 'Zone #2: 1200 ppm detected. Ventilation required.',
        'time': '2 mins ago',
        'color': const Color(0xFFF87171),
        'icon': Icons.warning_amber_rounded,
      },
      {
        'title': 'Motion Detected',
        'message': 'Zone #1: Unexpected movement at 22:45.',
        'time': '15 mins ago',
        'color': Colors.orangeAccent,
        'icon': Icons.run_circle_outlined,
      },
      {
        'title': 'System Update',
        'message': 'Gateway v2.4 successfully updated.',
        'time': '1 hour ago',
        'color': const Color(0xFF4ADE80),
        'icon': Icons.check_circle_outline,
      },
      {
        'title': 'Low Battery',
        'message': 'Sensor #4 (Temp) battery at 15%.',
        'time': '3 hours ago',
        'color': Colors.blueAccent,
        'icon': Icons.battery_alert,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SYSTEM ALERTS',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            right: 100,
            child: _buildGlow(const Color(0xFF38BDF8).withValues(alpha: 0.05)),
          ),
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return AlertCard(
                title: alert['title'] as String,
                message: alert['message'] as String,
                time: alert['time'] as String,
                color: alert['color'] as Color,
                icon: alert['icon'] as IconData,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}
