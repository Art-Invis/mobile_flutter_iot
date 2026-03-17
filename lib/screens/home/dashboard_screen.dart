import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';

import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/indicator.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalUserRepository _repository = LocalUserRepository();
  List<DeviceModel> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final savedDevices = await _repository.getDevices();
    if (!mounted) return;
    setState(() {
      _devices = savedDevices;
      _isLoading = false;
    });
  }

  Future<void> _syncData() async {
    await _repository.saveDevices(_devices);
  }

  void _onAddPressed() async {
    final DeviceModel? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => _devices.add(result));
      await _syncData();
    }
  }

  void _onEditDevice(DeviceModel device, int index) async {
    final DeviceModel? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDeviceScreen(device: device)),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => _devices[index] = result);
      await _syncData();
    }
  }

  void _onDeleteDevice(int index) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Sensor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _devices.removeAt(index));
              await _syncData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStatusCard(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _devices.isEmpty
                  ? _buildEmptyState()
                  : _buildDeviceList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        backgroundColor: const Color(0xFF38BDF8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'DASHBOARD',
        style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusCard() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: GlassCard(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            SystemPulseIndicator(),
            SizedBox(width: 12),
            Text(
              'SYSTEM: ONLINE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              'MQTT ACTIVE',
              style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No devices found.\nTap + to add.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white30),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index >= _devices.length) return const SizedBox.shrink();

        final device = _devices[index];
        final String deviceId = device.id.length > 8
            ? device.id.substring(0, 8)
            : device.id;

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              '/details',
              arguments: SensorArguments(
                id: device.id,
                title: device.title,
                value: device.value,
                icon: device.icon,
                color: device.color,
              ),
            );

            if (!mounted) return;

            if (result is Map && result.containsKey('deleteId')) {
              _onDeleteDevice(index);
            } else {
              _loadDevices();
            }
          },
          onLongPress: () => _onEditDevice(device, index),
          child: WorkspaceCard(
            id: device.id,
            title: device.title,
            value: device.value,
            status: device.status,
            subtitle: 'ID: $deviceId',
            icon: device.icon,
            accentColor: device.color,
          ),
        );
      },
    );
  }
}
