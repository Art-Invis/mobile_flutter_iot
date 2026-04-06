import 'package:equatable/equatable.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<DeviceModel> devices;
  final bool isOffline;

  const DeviceLoaded(this.devices, {this.isOffline = false});

  @override
  List<Object?> get props => [devices, isOffline];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}
