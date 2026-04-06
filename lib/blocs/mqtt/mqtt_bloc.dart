import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/blocs/mqtt/mqtt_event.dart';
import 'package:mobile_flutter_iot/blocs/mqtt/mqtt_state.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final ApiService _apiService;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSub;
  bool _hasLoggedReadViolation = false;

  MqttBloc({required ApiService apiService})
      : _apiService = apiService,
        super(const MqttState()) {
    on<MqttInitializeRequested>(_onInitialize);
    on<MqttConnectRequested>(_onConnect);
    on<MqttDisconnectRequested>(_onDisconnect);
    on<MqttToggleHardwareRequested>(_onToggleHardware);
    on<MqttMessageReceived>(_onMessageReceived);
    on<MqttUpdateLockHoursRequested>(_onUpdateLockHours);
  }

  void _onInitialize(MqttInitializeRequested event, Emitter<MqttState> emit) {
    final client = MqttServerClient(event.serverIp, event.clientId)
      ..port = 1883
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..autoReconnect = true;

    client.onDisconnected = () => add(MqttDisconnectRequested());
    client.onConnected = () {
      _subscribeToTopics(client);
      emit(state.copyWith(status: MqttStatus.connected));
    };

    emit(
      state.copyWith(
        client: client,
        statusMessage: 'Initialized on ${event.serverIp}',
      ),
    );
  }

  Future<void> _onConnect(
    MqttConnectRequested event,
    Emitter<MqttState> emit,
  ) async {
    if (state.client == null || state.status == MqttStatus.connected) return;

    emit(
      state.copyWith(
        status: MqttStatus.connecting,
        statusMessage: 'Connecting...',
      ),
    );

    try {
      await state.client!.connect();
    } catch (e) {
      log('MQTT ERROR: $e');
      state.client?.disconnect();
      emit(
        state.copyWith(status: MqttStatus.error, statusMessage: 'Error: $e'),
      );
    }
  }

  void _subscribeToTopics(MqttServerClient client) {
    client.subscribe('sensors/air', MqttQos.atMostOnce);

    _updatesSub?.cancel();
    _updatesSub = client.updates!.listen((messages) {
      final recMess = messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      add(MqttMessageReceived('sensors/air', payload));
    });
  }

  Future<void> _onMessageReceived(
    MqttMessageReceived event,
    Emitter<MqttState> emit,
  ) async {
    if (_isTimeRestricted()) {
      if (!_hasLoggedReadViolation) {
        await _apiService.saveLog(
          'SECURITY_POLICY',
          'Blocked stream at (${DateTime.now().hour}:00)',
        );
        _hasLoggedReadViolation = true;
      }
      emit(state.copyWith(airQuality: '0'));
      return;
    }

    _hasLoggedReadViolation = false;
    emit(state.copyWith(airQuality: event.message));
  }

  Future<void> _onToggleHardware(
    MqttToggleHardwareRequested event,
    Emitter<MqttState> emit,
  ) async {
    if (state.client == null || state.status != MqttStatus.connected) return;

    if (_isTimeRestricted()) {
      await _apiService.saveLog(
        'SECURITY_POLICY',
        'LED blocked at (${DateTime.now().hour}:00)',
      );
      return;
    }

    final builder = MqttClientPayloadBuilder()
      ..addString(event.isOn ? 'ON' : 'OFF');

    state.client!
        .publishMessage('commands/led', MqttQos.atMostOnce, builder.payload!);

    emit(state.copyWith(isLedOn: event.isOn));
  }

  void _onDisconnect(MqttDisconnectRequested event, Emitter<MqttState> emit) {
    state.client?.disconnect();
    _updatesSub?.cancel();
    emit(
      state.copyWith(
        status: MqttStatus.disconnected,
        statusMessage: 'Disconnected',
      ),
    );
  }

  void _onUpdateLockHours(
    MqttUpdateLockHoursRequested event,
    Emitter<MqttState> emit,
  ) {
    emit(
      state.copyWith(
        startLockHour: event.startHour,
        endLockHour: event.endHour,
      ),
    );
  }

  bool _isTimeRestricted() {
    final hour = DateTime.now().hour;
    if (state.startLockHour > state.endLockHour) {
      return hour >= state.startLockHour || hour < state.endLockHour;
    }
    return hour >= state.startLockHour && hour < state.endLockHour;
  }

  @override
  Future<void> close() {
    _updatesSub?.cancel();
    state.client?.disconnect();
    return super.close();
  }
}
