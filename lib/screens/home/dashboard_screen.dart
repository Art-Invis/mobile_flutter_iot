import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
import 'package:mobile_flutter_iot/widgets/api_device_list.dart';
import 'package:mobile_flutter_iot/widgets/mqtt_section.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late ShakeDetector _shakeDetector;
  bool _isFirstCheck = true;
  int _listKey = 0;

  @override
  void initState() {
    super.initState();
    _initConnectivityMonitoring();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safelyConnectMQTT();
    });

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) => _handleShake(),
      shakeThresholdGravity: 1.5,
    );
  }

  void _initConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!mounted) return;

        final bool hasNet = !results.contains(ConnectivityResult.none);
        final mqtt = Provider.of<MqttProvider>(context, listen: false);

        if (!hasNet) {
          _isFirstCheck = false;
          _showBanner('OFFLINE: Check your Wi-Fi connection', Colors.redAccent);
          mqtt.disconnect();
        } else {
          if (!_isFirstCheck) {
            _showBanner('ONLINE: Connection restored!', Colors.green);
            setState(
              () => _listKey++,
            );
          }
          _isFirstCheck = false;

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _safelyConnectMQTT();
          });
        }
      },
    );
  }

  void _showBanner(String msg, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
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

  void _handleShake() {
    if (!mounted) return;
    _showBanner('SHAKE: Data refreshed', const Color(0xFF38BDF8));
    setState(() => _listKey++);
  }

  @override
  void dispose() {
    _shakeDetector.stopListening();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() => _listKey++),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                MqttSection(mqtt: mqtt),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'CLOUD & LOCAL NODES',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                ApiDeviceList(
                  key: ValueKey(
                    _listKey,
                  ),
                  mqttIp: mqtt.client?.server,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<DeviceModel?>(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
          if (result != null && mounted) {
            await LocalUserRepository().saveDevices(
              [result],
            );
            setState(() => _listKey++);
          }
        },
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
}
