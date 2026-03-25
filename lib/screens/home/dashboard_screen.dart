import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/indicator.dart';
import 'package:mobile_flutter_iot/widgets/workspace_card.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalUserRepository _repository = LocalUserRepository();
  List<DeviceModel> _devices = [];
  bool _isLoading = true;
  late ShakeDetector _shakeDetector;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _initConnectivityMonitoring();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safelyConnectMQTT();
    });

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) => _handleShake(),
      shakeThresholdGravity: 1.5,
    );
  }

  bool _isFirstCheck = true;

  void _initConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!mounted) return;

        final bool hasNet = !results.contains(ConnectivityResult.none);
        final mqtt = Provider.of<MqttProvider>(context, listen: false);

        if (!hasNet) {
          _isFirstCheck = false;
          _showStatusBanner(
            'OFFLINE: Check your Wi-Fi connection',
            Colors.redAccent,
          );
          mqtt.disconnect();
        } else {
          if (!_isFirstCheck) {
            _showStatusBanner('ONLINE: Connection restored!', Colors.green);
          }
          _isFirstCheck = false;

          debugPrint('Network is back! Attempting MQTT Sync...');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _safelyConnectMQTT();
          });
        }
      },
    );
  }

  void _showStatusBanner(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _safelyConnectMQTT() async {
    final mqtt = Provider.of<MqttProvider>(context, listen: false);
    if (mqtt.client == null) {
      mqtt.initMqtt('192.168.1.XXX', 'flutter_client_${Random().nextInt(100)}');
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.none)) {
      mqtt.connect();
    }
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _handleShake() async {
    if (!mounted || _devices.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SHAKE: Local nodes refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
    final random = Random();
    for (var device in _devices) {
      device.value = device.title.toLowerCase().contains('temp')
          ? '${20 + random.nextInt(10)}°C'
          : '${random.nextInt(100)} units';
    }
    await _syncData();
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

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
    final bool isMqttLive = mqtt.status == MqttStatus.connected;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStatusCard(mqtt),
            if (isMqttLive) ...[
              _buildMqttLiveNode(mqtt),
              _buildMqttControlNode(mqtt),
            ],
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_devices.isEmpty && !isMqttLive)
                      ? _buildEmptyState()
                      : _buildDeviceList(mqtt),
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

  Widget _buildStatusCard(MqttProvider mqtt) {
    final bool isConnected = mqtt.status == MqttStatus.connected;

    final Color statusColor = mqtt.status == MqttStatus.connected
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);
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

  Widget _buildMqttLiveNode(MqttProvider mqtt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
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
          );
        },
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

  Widget _buildMqttControlNode(MqttProvider mqtt) {
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

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No active nodes found.\nConnect ESP8266 or add manually.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white30),
      ),
    );
  }

  Widget _buildDeviceList(MqttProvider mqtt) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final device = _devices[index];
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
                ipAddress: mqtt.client?.server ?? '192.168.1.XXX',
              ),
            );
            if (mounted) _loadDevices();
          },
          onLongPress: () => _onEditDevice(device, index),
          child: WorkspaceCard(
            id: device.id,
            title: device.title,
            value: device.value,
            status: device.status,
            subtitle: 'Local simulation',
            icon: device.icon,
            accentColor: device.color,
          ),
        );
      },
    );
  }

  void _onAddPressed() async {
    final result = await Navigator.push<DeviceModel?>(
      context,
      MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
    );
    if (mounted && result != null) {
      setState(() => _devices.add(result));
      _syncData();
    }
  }

  void _onEditDevice(DeviceModel device, int index) async {
    final result = await Navigator.push<DeviceModel?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddDeviceScreen(device: device),
      ),
    );
    if (mounted && result != null) {
      setState(() => _devices[index] = result);
      _syncData();
    }
  }
}
