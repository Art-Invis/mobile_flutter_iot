import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttStatus { disconnected, connecting, connected, error }

class MqttProvider with ChangeNotifier {
  MqttServerClient? client;
  MqttStatus _status = MqttStatus.disconnected;
  String _airQuality = '0';
  bool _isLedOn = false;

  MqttStatus get status => _status;
  String get airQuality => _airQuality;
  bool get isLedOn => _isLedOn;

  void initMqtt(String broker, String clientId) {
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
      (List<MqttReceivedMessage<MqttMessage>> messages) {
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

  void toggleLed() {
    if (client == null || _status != MqttStatus.connected) return;
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
