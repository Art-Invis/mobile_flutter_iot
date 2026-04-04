import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MqttStatus { disconnected, connecting, connected, error }

class MqttState {
  final MqttStatus status;
  final String airQuality;
  final bool isLedOn;
  final int startLockHour;
  final int endLockHour;
  final MqttServerClient? client;

  const MqttState({
    this.status = MqttStatus.disconnected,
    this.airQuality = '0',
    this.isLedOn = false,
    this.startLockHour = 22,
    this.endLockHour = 6,
    this.client,
  });

  MqttState copyWith({
    MqttStatus? status,
    String? airQuality,
    bool? isLedOn,
    int? startLockHour,
    int? endLockHour,
    MqttServerClient? client,
  }) {
    return MqttState(
      status: status ?? this.status,
      airQuality: airQuality ?? this.airQuality,
      isLedOn: isLedOn ?? this.isLedOn,
      startLockHour: startLockHour ?? this.startLockHour,
      endLockHour: endLockHour ?? this.endLockHour,
      client: client ?? this.client,
    );
  }
}

class MqttCubit extends Cubit<MqttState> {
  final ApiService _apiService;
  bool _hasLoggedReadViolation = false;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSub;

  MqttCubit({required ApiService apiService})
      : _apiService = apiService,
        super(const MqttState());

  Future<void> loadLockPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    emit(
      state.copyWith(
        startLockHour: prefs.getInt('start_lock') ?? 22,
        endLockHour: prefs.getInt('end_lock') ?? 6,
      ),
    );
  }

  Future<void> updateLockHours(int start, int end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('start_lock', start);
    await prefs.setInt('end_lock', end);
    _hasLoggedReadViolation = false;
    emit(state.copyWith(startLockHour: start, endLockHour: end));
  }

  bool isTimeRestricted() {
    final hour = DateTime.now().hour;
    if (state.startLockHour > state.endLockHour) {
      return hour >= state.startLockHour || hour < state.endLockHour;
    }
    return hour >= state.startLockHour && hour < state.endLockHour;
  }

  void initMqtt(String broker, String clientId) {
    loadLockPolicy();
    final client = MqttServerClient(broker, clientId)
      ..port = 1883
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..autoReconnect = true;

    client.onDisconnected =
        () => emit(state.copyWith(status: MqttStatus.disconnected));
    client.onConnected = () {
      emit(state.copyWith(status: MqttStatus.connected, client: client));
      _subscribeToTopics();
    };

    emit(state.copyWith(client: client));
  }

  Future<void> connect() async {
    if (state.client == null ||
        state.status == MqttStatus.connected ||
        state.status == MqttStatus.connecting) {
      return;
    }
    emit(state.copyWith(status: MqttStatus.connecting));
    try {
      await state.client!.connect();
    } catch (e) {
      debugPrint('MQTT ERROR: $e');
      if (state.client?.connectionStatus?.state !=
          MqttConnectionState.disconnected) {
        state.client?.disconnect();
      }
      emit(state.copyWith(status: MqttStatus.error));
    }
  }

  void _subscribeToTopics() {
    if (state.client == null || state.status != MqttStatus.connected) return;
    state.client!.subscribe('sensors/air', MqttQos.atMostOnce);

    _updatesSub?.cancel();
    _updatesSub = state.client!.updates!.listen((messages) async {
      if (isTimeRestricted()) {
        emit(state.copyWith(airQuality: '0'));
        if (!_hasLoggedReadViolation) {
          await _apiService.saveLog(
            'SECURITY_POLICY',
            'VIOLATION: Blocked stream at (${DateTime.now().hour}:00)',
          );
          _hasLoggedReadViolation = true;
        }
        return;
      }
      _hasLoggedReadViolation = false;
      final recMess = messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      emit(state.copyWith(airQuality: payload));
    });
  }

  Future<void> toggleLed() async {
    if (state.client == null || state.status != MqttStatus.connected) return;
    if (isTimeRestricted()) {
      await _apiService.saveLog(
        'SECURITY_POLICY',
        'VIOLATION: LED control blocked at (${DateTime.now().hour}:00)',
      );
      return;
    }
    final newState = !state.isLedOn;
    final builder = MqttClientPayloadBuilder()
      ..addString(newState ? 'ON' : 'OFF');
    state.client!
        .publishMessage('commands/led', MqttQos.atMostOnce, builder.payload!);
    emit(state.copyWith(isLedOn: newState));
  }

  void disconnect() {
    state.client?.disconnect();
    _updatesSub?.cancel();
    emit(state.copyWith(status: MqttStatus.disconnected));
  }

  @override
  Future<void> close() {
    _updatesSub?.cancel();
    state.client?.disconnect();
    return super.close();
  }
}
