import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/cubits/mqtt_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttDialogs {
  static Future<void> showEditIpAddress(
    BuildContext context,
    MqttCubit mqttCubit,
    MqttState state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    final currentIp =
        state.client?.server ?? prefs.getString('mqtt_ip') ?? '192.168.1.XXX';
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

      mqttCubit.disconnect();
      mqttCubit.initMqtt(newIp, 'flutter_client_${Random().nextInt(100)}');
      mqttCubit.connect();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reconnecting to $newIp...'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  static Future<void> showSetLockPolicy(
    BuildContext context,
    MqttCubit mqttCubit,
    MqttState state,
  ) async {
    final startController =
        TextEditingController(text: state.startLockHour.toString());
    final endController =
        TextEditingController(text: state.endLockHour.toString());

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Admin Security Policy',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set hours when LED control is disabled.'
              'Actions will be logged to the server.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Lock From (Hour)',
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Unlock At (Hour)',
                      labelStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final start = int.tryParse(startController.text) ?? 22;
              final end = int.tryParse(endController.text) ?? 6;
              mqttCubit.updateLockHours(start, end);
              Navigator.pop(context);
            },
            child: const Text(
              'Save Policy',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
