import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';

class ApiDeviceList extends StatefulWidget {
  final String? mqttIp;
  const ApiDeviceList({this.mqttIp, super.key});

  @override
  State<ApiDeviceList> createState() => _ApiDeviceListState();
}

class _ApiDeviceListState extends State<ApiDeviceList> {
  final ApiService _apiService = ApiService();
  final LocalUserRepository _cache = LocalUserRepository();

  late Future<List<DeviceModel>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _devicesFuture = _fetchAndSyncDevices();
    });
  }

  Future<List<DeviceModel>> _fetchAndSyncDevices() async {
    try {
      final cloudDevices = await _apiService.fetchDevices();
      if (cloudDevices != null && cloudDevices.isNotEmpty) {
        await _cache.saveDevices(cloudDevices);
        return cloudDevices;
      }
    } catch (e) {
      debugPrint('API Error, falling back to cache: $e');
    }
    return await _cache.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeviceModel>>(
      future: _devicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

        final devices = snapshot.data!;
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
                    ipAddress: widget.mqttIp ?? 'No IP',
                  ),
                );
                _refreshData();
              },
              onLongPress: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => AddDeviceScreen(device: device),
                  ),
                );
                _refreshData();
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
      },
    );
  }
}
