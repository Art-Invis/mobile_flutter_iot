import 'package:equatable/equatable.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class DeviceFetchRequested extends DeviceEvent {}

class DeviceAddRequested extends DeviceEvent {
  final DeviceModel device;
  const DeviceAddRequested(this.device);
  @override
  List<Object?> get props => [device];
}

class DeviceUpdateRequested extends DeviceEvent {
  final DeviceModel device;
  const DeviceUpdateRequested(this.device);
  @override
  List<Object?> get props => [device];
}

class DeviceDeleteRequested extends DeviceEvent {
  final String deviceId;
  const DeviceDeleteRequested(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}
