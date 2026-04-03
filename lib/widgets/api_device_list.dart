import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/device_cubit.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';

class ApiDeviceList extends StatelessWidget {
  final List<DeviceModel> devices;
  final String? mqttIp;

  const ApiDeviceList({required this.devices, this.mqttIp, super.key});

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No devices found.\nAdd one manually or connect ESP.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white30),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final device = devices[index];

        return GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(
              context,
              '/details',
              arguments: SensorArguments(
                id: device.id,
                title: device.title,
                value: device.value,
                icon: device.icon,
                color: device.color,
                ipAddress: mqttIp ?? 'No IP',
              ),
            );
            if (context.mounted) {
              context.read<DeviceCubit>().loadDevices();
            }
          },
          onLongPress: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => AddDeviceScreen(device: device),
              ),
            );
            if (context.mounted) {
              context.read<DeviceCubit>().loadDevices();
            }
          },
          child: WorkspaceCard(
            id: device.id,
            title: device.title,
            value: device.value,
            status: device.status,
            subtitle: 'Cloud / Local',
            icon: device.icon,
            accentColor: device.color,
          ),
        );
      },
    );
  }
}
