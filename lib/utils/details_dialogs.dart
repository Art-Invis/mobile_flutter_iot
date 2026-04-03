import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/details_cubit.dart';
import 'package:mobile_flutter_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';

class DetailsDialogs {
  static Future<void> showDeleteDevice(
    BuildContext context,
    String deviceId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text('Delete Sensor?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently remove the device from the cloud.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<DetailsCubit>().deleteDevice(deviceId);
    }
  }

  static Future<void> showEditIpAddress(
    BuildContext context,
    SensorArguments args,
    String? currentCustomIp,
  ) async {
    final mqttCubit = context.read<MqttCubit>();
    final controller =
        TextEditingController(text: currentCustomIp ?? args.ipAddress);

    final newIp = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Edit Device IP / Broker'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. 192.168.1.XXX',
            labelText: 'Target IP Address',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text(
              'Update & Reconnect',
              style: TextStyle(color: Color(0xFF4ADE80)),
            ),
          ),
        ],
      ),
    );

    if (newIp != null && newIp.isNotEmpty && context.mounted) {
      context.read<DetailsCubit>().updateIp(newIp);
      mqttCubit.disconnect();
      mqttCubit.initMqtt(newIp, 'flutter_client_reconnect');
      mqttCubit.connect();
    }
  }

  static Future<void> showEditValue(
    BuildContext context,
    SensorArguments args,
    String? currentValue,
  ) async {
    final controller = TextEditingController(text: currentValue ?? args.value);

    final newValue = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit ${args.title} Value'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration:
              const InputDecoration(hintText: 'Enter new value (e.g. 25.5°C)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child:
                const Text('Save', style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty && context.mounted) {
      context.read<DetailsCubit>().updateValue(args.id, newValue);
    }
  }
}
