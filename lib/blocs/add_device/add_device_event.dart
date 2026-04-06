import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';

abstract class AddDeviceEvent extends Equatable {
  const AddDeviceEvent();

  @override
  List<Object?> get props => [];
}

class AddDeviceColorChanged extends AddDeviceEvent {
  final Color color;
  const AddDeviceColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class AddDeviceIconChanged extends AddDeviceEvent {
  final IconData icon;
  const AddDeviceIconChanged(this.icon);
  @override
  List<Object?> get props => [icon];
}

class AddDeviceSaveRequested extends AddDeviceEvent {
  final DeviceModel device;
  final bool isNew;
  const AddDeviceSaveRequested({required this.device, required this.isNew});
  @override
  List<Object?> get props => [device, isNew];
}
