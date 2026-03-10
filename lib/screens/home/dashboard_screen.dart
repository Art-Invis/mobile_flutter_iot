import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/indicator.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorData = [
      {
        'title': 'Air Quality (MQ135)',
        'value': '420 ppm',
        'status': 'EXCELLENT',
        'icon': Icons.air,
        'color': const Color(0xFF4ADE80),
        'subtitle': 'Sensor R0: 76.63',
      },
      {
        'title': 'Climate Control',
        'value': '22.4°C',
        'status': 'AUTO MODE',
        'icon': Icons.ac_unit,
        'color': const Color(0xFF38BDF8),
        'subtitle': 'Fan: Idle',
      },
      {
        'title': 'Motion Security',
        'value': 'No Motion',
        'status': 'SECURE',
        'icon': Icons.sensors,
        'color': Colors.orangeAccent,
        'subtitle': 'Light: Auto-off',
      },
      {
        'title': 'System Stats',
        'value': '78% Health',
        'status': 'All Nominal',
        'icon': Icons.analytics_outlined,
        'color': Colors.purpleAccent,
        'subtitle': 'Uptime: 12h 45m',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -100,
            child: _buildBlurBlob(
              const Color(0xFF38BDF8).withValues(alpha: 0.05),
              300,
            ),
          ),
          Positioned(
            bottom: 50,
            left: -100,
            child: _buildBlurBlob(
              const Color(0xFF4ADE80).withValues(alpha: 0.03),
              350,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'DASHBOARD',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: GlassCard(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Row(
                      children: [
                        SystemPulseIndicator(),
                        SizedBox(width: 12),
                        Text(
                          'Monitor SYSTEM: ONLINE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'MQTT ACTIVE',
                          style: TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sensorData.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = sensorData[index];
                      return WorkspaceCard(
                        title: item['title'] as String,
                        value: item['value'] as String,
                        status: item['status'] as String,
                        subtitle: item['subtitle'] as String,
                        icon: item['icon'] as IconData,
                        accentColor: item['color'] as Color,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // ignore: avoid_print
        onPressed: () => print('Scan...'),
        backgroundColor: const Color(0xFF38BDF8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
