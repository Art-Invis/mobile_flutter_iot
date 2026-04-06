import 'package:equatable/equatable.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttStatus { disconnected, connecting, connected, error }

class MqttState extends Equatable {
  final MqttServerClient? client;
  final MqttStatus status;
  final bool isLedOn;
  final String statusMessage;
  final String airQuality;
  final int startLockHour;
  final int endLockHour;

  const MqttState({
    this.client,
    this.status = MqttStatus.disconnected,
    this.isLedOn = false,
    this.statusMessage = 'Disconnected',
    this.airQuality = '0.0',
    this.startLockHour = 22,
    this.endLockHour = 6,
  });

  MqttState copyWith({
    MqttServerClient? client,
    MqttStatus? status,
    bool? isLedOn,
    String? statusMessage,
    String? airQuality,
    int? startLockHour,
    int? endLockHour,
  }) {
    return MqttState(
      client: client ?? this.client,
      status: status ?? this.status,
      isLedOn: isLedOn ?? this.isLedOn,
      statusMessage: statusMessage ?? this.statusMessage,
      airQuality: airQuality ?? this.airQuality,
      startLockHour: startLockHour ?? this.startLockHour,
      endLockHour: endLockHour ?? this.endLockHour,
    );
  }

  @override
  List<Object?> get props => [
        client,
        status,
        isLedOn,
        statusMessage,
        airQuality,
        startLockHour,
        endLockHour,
      ];
}
