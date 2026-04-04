import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/utils/mqtt_dialogs.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/common/indicator.dart';
import 'package:mobile_flutter_iot/widgets/common/workspace_card.dart';
import 'package:mobile_flutter_iot/widgets/mqtt/mqtt_control_card.dart';

class MqttSection extends StatelessWidget {
  final MqttState mqttState;
  const MqttSection({required this.mqttState, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isConnected = mqttState.status == MqttStatus.connected;

    return Column(
      children: [
        _buildStatusCard(context, isConnected),
        if (isConnected) ...[
          _buildMqttLiveNode(context),
          MqttControlCard(mqttState: mqttState),
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
            GestureDetector(
              onTap: () => MqttDialogs.showEditIpAddress(
                context,
                context.read<MqttCubit>(),
                mqttState,
              ),
              child: Row(
                children: [
                  Text(
                    mqttState.client?.server ?? 'No IP',
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
        double.tryParse(mqttState.airQuality.toString()) ?? 0.0;
    final bool isSensorOffline = currentAqi == 0.0;

    final String displayValue =
        isSensorOffline ? 'No Data' : '${mqttState.airQuality} AQI';
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
            ipAddress: mqttState.client?.server ?? '192.168.1.XXX',
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
}
