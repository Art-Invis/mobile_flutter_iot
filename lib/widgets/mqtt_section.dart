import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/indicator.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttSection extends StatelessWidget {
  final MqttProvider mqtt;
  const MqttSection({required this.mqtt, super.key});

  // НОВЕ: Метод для зміни IP прямо з дашборду
  Future<void> _editIpAddress(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    if (!context.mounted) return;

    final currentIp =
        mqtt.client?.server ?? prefs.getString('mqtt_ip') ?? '192.168.1.XXX';
    final controller = TextEditingController(text: currentIp);

    final newIp = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text('Set Broker IP', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. 192.168.1.100',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text(
              'Save & Reconnect',
              style: TextStyle(color: Color(0xFF4ADE80)),
            ),
          ),
        ],
      ),
    );

    if (newIp != null && newIp.isNotEmpty && context.mounted) {
      await prefs.setString('mqtt_ip', newIp);

      if (!context.mounted) return;

      mqtt.disconnect();
      mqtt.initMqtt(newIp, 'flutter_client_${Random().nextInt(100)}');
      mqtt.connect();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reconnecting to $newIp...'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConnected = mqtt.status == MqttStatus.connected;

    return Column(
      children: [
        _buildStatusCard(context, isConnected),
        if (isConnected) ...[
          _buildMqttLiveNode(context),
          _buildMqttControlNode(),
        ],
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isConnected) {
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
            // Зробили IP клікабельним
            GestureDetector(
              onTap: () => _editIpAddress(context),
              child: Row(
                children: [
                  Text(
                    mqtt.client?.server ?? 'No IP',
                    style: const TextStyle(fontSize: 10, color: Colors.white24),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 10, color: Colors.white24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMqttLiveNode(BuildContext context) {
    final double currentAqi =
        double.tryParse(mqtt.airQuality.toString()) ?? 0.0;
    final bool isSensorOffline = currentAqi == 0.0;

    final String displayValue =
        isSensorOffline ? 'No Data' : '${mqtt.airQuality} AQI';
    final String displayStatus = isSensorOffline ? 'SENSOR OFFLINE' : 'LIVE';
    final Color displayColor =
        isSensorOffline ? Colors.white24 : const Color(0xFF38BDF8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/details',
          arguments: SensorArguments(
            id: 'ESP_AIR_01',
            title: 'Air Quality',
            value: displayValue,
            icon: Icons.air_rounded,
            color: displayColor,
            status: displayStatus,
            ipAddress: mqtt.client?.server ?? '192.168.1.XXX',
          ),
        ),
        child: WorkspaceCard(
          id: 'ESP_AIR_01',
          title: 'Air Quality (ESP8266)',
          value: displayValue,
          status: displayStatus,
          subtitle:
              isSensorOffline ? 'Check hardware power' : 'Real-time MQTT data',
          icon: Icons.air_rounded,
          accentColor: displayColor,
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
