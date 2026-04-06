import 'package:equatable/equatable.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();

  @override
  List<Object?> get props => [];
}

class MqttInitializeRequested extends MqttEvent {
  final String serverIp;
  final String clientId;

  const MqttInitializeRequested(this.serverIp, this.clientId);

  @override
  List<Object?> get props => [serverIp, clientId];
}

class MqttConnectRequested extends MqttEvent {}

class MqttDisconnectRequested extends MqttEvent {}

class MqttToggleHardwareRequested extends MqttEvent {
  final bool isOn;

  const MqttToggleHardwareRequested(this.isOn);

  @override
  List<Object?> get props => [isOn];
}

class MqttMessageReceived extends MqttEvent {
  final String topic;
  final String message;

  const MqttMessageReceived(this.topic, this.message);

  @override
  List<Object?> get props => [topic, message];
}

class MqttUpdateLockHoursRequested extends MqttEvent {
  final int startHour;
  final int endHour;

  const MqttUpdateLockHoursRequested(this.startHour, this.endHour);

  @override
  List<Object?> get props => [startHour, endHour];
}
