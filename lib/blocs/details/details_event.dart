import 'package:equatable/equatable.dart';

abstract class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object?> get props => [];
}

class DetailsToggleManualControlRequested extends DetailsEvent {
  final bool isOn;
  const DetailsToggleManualControlRequested(this.isOn);
  @override
  List<Object?> get props => [isOn];
}

class DetailsSaveSnapshotRequested extends DetailsEvent {
  final String sensorId;
  final String value;
  const DetailsSaveSnapshotRequested(this.sensorId, this.value);
  @override
  List<Object?> get props => [sensorId, value];
}

class DetailsUpdateIpRequested extends DetailsEvent {
  final String newIp;
  const DetailsUpdateIpRequested(this.newIp);
  @override
  List<Object?> get props => [newIp];
}

class DetailsUpdateValueRequested extends DetailsEvent {
  final String newValue;
  const DetailsUpdateValueRequested(this.newValue);
  @override
  List<Object?> get props => [newValue];
}

class DetailsDeleteDeviceRequested extends DetailsEvent {
  final String deviceId;
  const DetailsDeleteDeviceRequested(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}
