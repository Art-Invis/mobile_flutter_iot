import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MqttStatus { disconnected, connecting, connected, error }

class MqttProvider with ChangeNotifier {
  MqttServerClient? client;
  MqttStatus _status = MqttStatus.disconnected;
  String _airQuality = '0';
  bool _isLedOn = false;
  final ApiService _apiService = ApiService();

  int startLockHour = 22;
  int endLockHour = 6;

  bool _hasLoggedReadViolation = false;

  MqttStatus get status => _status;
  String get airQuality => _airQuality;
  bool get isLedOn => _isLedOn;

  Future<void> loadLockPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    startLockHour = prefs.getInt('start_lock') ?? 22;
    endLockHour = prefs.getInt('end_lock') ?? 6;
    notifyListeners();
  }

  Future<void> updateLockHours(int start, int end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('start_lock', start);
    await prefs.setInt('end_lock', end);
    startLockHour = start;
    endLockHour = end;

    _hasLoggedReadViolation = false;
    notifyListeners();
  }

  bool isTimeRestricted() {
    final now = DateTime.now();
    final hour = now.hour;

    if (startLockHour > endLockHour) {
      return hour >= startLockHour || hour < endLockHour;
    } else {
      return hour >= startLockHour && hour < endLockHour;
    }
  }

  void initMqtt(String broker, String clientId) {
    loadLockPolicy();

    client = MqttServerClient(broker, clientId);
    client!.port = 1883;
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;
    client!.autoReconnect = true;

    client!.onDisconnected = () {
      _status = MqttStatus.disconnected;
      notifyListeners();
    };

    client!.onConnected = () {
      _status = MqttStatus.connected;
      _subscribeToTopics();
      notifyListeners();
    };

    client!.onAutoReconnect = () => debugPrint('MQTT: Auto reconnecting...');
    client!.onAutoReconnected = () => debugPrint('MQTT: Auto reconnected');
  }

  Future<void> connect() async {
    if (client == null) return;
    if (_status == MqttStatus.connected || _status == MqttStatus.connecting) {
      return;
    }

    _status = MqttStatus.connecting;
    notifyListeners();

    try {
      await client!.connect();
    } catch (e) {
      debugPrint('MQTT ERROR: $e');
      _status = MqttStatus.error;
      if (client?.connectionStatus?.state != MqttConnectionState.disconnected) {
        client?.disconnect();
      }
      notifyListeners();
    }
  }

  void _subscribeToTopics() {
    if (client == null || _status != MqttStatus.connected) return;

    client!.subscribe('sensors/air', MqttQos.atMostOnce);

    client!.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) async {
        if (isTimeRestricted()) {
          _airQuality = '0';
          notifyListeners();

          if (!_hasLoggedReadViolation) {
            await _apiService.saveLog(
              'SECURITY_POLICY',
              'VIOLATION: Blocked incoming telemetry stream'
                  'at (${DateTime.now().hour}:00)',
            );
            _hasLoggedReadViolation = true;
            debugPrint('Read blocked by time policy');
          }
          return;
        }

        _hasLoggedReadViolation = false;

        final recMess = messages[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _airQuality = payload;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('MQTT Stream Error: $error');
      },
      cancelOnError: false,
    );
  }

  Future<void> toggleLed() async {
    if (client == null || _status != MqttStatus.connected) return;

    if (isTimeRestricted()) {
      await _apiService.saveLog(
        'SECURITY_POLICY',
        'VIOLATION: Attempted to control LED'
            'at restricted time (${DateTime.now().hour}:00)',
      );
      debugPrint('Action blocked by time policy');
      return;
    }

    try {
      _isLedOn = !_isLedOn;
      final builder = MqttClientPayloadBuilder();
      builder.addString(_isLedOn ? 'ON' : 'OFF');
      client!
          .publishMessage('commands/led', MqttQos.atMostOnce, builder.payload!);
      notifyListeners();
    } catch (e) {
      debugPrint('MQTT Publish Error: $e');
    }
  }

  void disconnect() {
    try {
      client?.disconnect();
    } catch (e) {
      debugPrint('MQTT Disconnect Error: $e');
    }
    _status = MqttStatus.disconnected;
    notifyListeners();
  }
}
