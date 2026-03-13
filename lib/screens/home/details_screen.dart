import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/sensor_chart.dart';

class SensorArguments {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  SensorArguments({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? rawArgs = ModalRoute.of(context)?.settings.arguments;

    if (rawArgs == null || rawArgs is! SensorArguments) {
      return const _ErrorDetailsView();
    }

    final args = rawArgs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${args.title.toUpperCase()} ANALYSIS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${args.title} History',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  const SensorChart(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Current Value',
                    args.value,
                    args.icon,
                    args.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStat(
                    'Status',
                    'Stable',
                    Icons.check_circle_outline,
                    const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: ListTile(
                leading: Icon(args.icon, color: args.color),
                title: Text('Manual ${args.title} Control'),
                trailing: Switch(
                  value: true,
                  onChanged: (v) {},
                  activeThumbColor: args.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color),
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

class _ErrorDetailsView extends StatelessWidget {
  const _ErrorDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ERROR')),
      body: const Center(
        child: Text(
          'Sensor data not found.\nPlease return to Dashboard.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
