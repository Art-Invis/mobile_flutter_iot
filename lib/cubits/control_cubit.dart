import 'package:flutter_bloc/flutter_bloc.dart';

class ControlState {
  final bool isLightOn;
  final double brightness;
  final bool isAcOn;
  final bool isVentOn;
  final bool isEmergencyTriggered;

  const ControlState({
    this.isLightOn = true,
    this.brightness = 0.7,
    this.isAcOn = true,
    this.isVentOn = false,
    this.isEmergencyTriggered = false,
  });

  ControlState copyWith({
    bool? isLightOn,
    double? brightness,
    bool? isAcOn,
    bool? isVentOn,
    bool? isEmergencyTriggered,
  }) {
    return ControlState(
      isLightOn: isLightOn ?? this.isLightOn,
      brightness: brightness ?? this.brightness,
      isAcOn: isAcOn ?? this.isAcOn,
      isVentOn: isVentOn ?? this.isVentOn,
      isEmergencyTriggered: isEmergencyTriggered ?? false,
    );
  }
}

class ControlCubit extends Cubit<ControlState> {
  ControlCubit() : super(const ControlState());

  void toggleLight(bool value) => emit(state.copyWith(isLightOn: value));

  void setBrightness(double value) => emit(state.copyWith(brightness: value));

  void toggleAc(bool value) => emit(state.copyWith(isAcOn: value));

  void toggleVent(bool value) => emit(state.copyWith(isVentOn: value));

  void emergencyShutdown() {
    emit(
      state.copyWith(
        isLightOn: false,
        brightness: 0,
        isAcOn: false,
        isVentOn: false,
        isEmergencyTriggered: true,
      ),
    );
  }
}
