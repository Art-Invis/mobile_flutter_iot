import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/indicator.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';

class MqttSection extends StatelessWidget {
  final MqttProvider mqtt;
  const MqttSection({required this.mqtt, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isConnected = mqtt.status == MqttStatus.connected;

    return Column(
      children: [
        _buildStatusCard(isConnected),
        if (isConnected) ...[
          _buildMqttLiveNode(context),
          _buildMqttControlNode(),
        ],
      ],
    );
  }

  Widget _buildStatusCard(bool isConnected) {
    final statusColor =
        isConnected ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            SystemPulseIndicator(color: statusColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SYSTEM ENGINE',
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
                Text(
                  isConnected ? 'ONLINE' : 'MQTT DISCONNECTED',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              mqtt.client?.server ?? 'No IP',
              style: const TextStyle(fontSize: 10, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMqttLiveNode(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/details',
          arguments: SensorArguments(
            id: 'ESP_AIR_01',
            title: 'Air Quality',
            value: '${mqtt.airQuality} AQI',
            icon: Icons.air_rounded,
            color: const Color(0xFF38BDF8),
            ipAddress: mqtt.client?.server ?? '192.168.1.XXX',
          ),
        ),
        child: WorkspaceCard(
          id: 'ESP_AIR_01',
          title: 'Air Quality (ESP8266)',
          value: '${mqtt.airQuality} AQI',
          status: 'LIVE',
          subtitle: 'Real-time MQTT data',
          icon: Icons.air_rounded,
          accentColor: const Color(0xFF38BDF8),
        ),
      ),
    );
  }

  Widget _buildMqttControlNode() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mqtt.isLedOn
                  ? Colors.yellow.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mqtt.isLedOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: mqtt.isLedOn ? Colors.yellow : Colors.white24,
            ),
          ),
          title: const Text(
            'Smart LED System',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            mqtt.isLedOn ? 'Active (ON)' : 'Inactive (OFF)',
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
          trailing: Switch(
            value: mqtt.isLedOn,
            activeThumbColor: Colors.yellow,
            onChanged: (_) => mqtt.toggleLed(),
          ),
        ),
      ),
    );
  }
}
