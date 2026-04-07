import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_flashlight/iot_flashlight.dart';
import 'package:shake/shake.dart';

class FlashlightState {
  final bool isOn;
  final String? errorMessage;

  const FlashlightState({this.isOn = false, this.errorMessage});

  FlashlightState copyWith({bool? isOn, String? errorMessage}) {
    return FlashlightState(
      isOn: isOn ?? this.isOn,
      errorMessage: errorMessage,
    );
  }
}

class FlashlightCubit extends Cubit<FlashlightState> {
  ShakeDetector? _detector;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  FlashlightCubit() : super(const FlashlightState()) {
    _initShakeDetector();
  }

  void _initShakeDetector() {
    _detector = ShakeDetector.autoStart(
      onPhoneShake: (_) {
        debugPrint('📳 Shake detected via Cubit!');
        toggleFlashlight();
      },
    );
  }

  Future<void> toggleFlashlight() async {
    try {
      final isOn = await IotFlashlight.toggle();
      emit(state.copyWith(isOn: isOn));
    } catch (e) {
      if (e.toString().contains('UNSUPPORTED_PLATFORM')) {
        emit(state.copyWith(errorMessage: 'UNSUPPORTED_PLATFORM'));
      } else {
        emit(state.copyWith(errorMessage: e.toString()));
      }
    }
  }

  void handleSecretTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(milliseconds: 500)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount == 5) {
      _tapCount = 0;
      toggleFlashlight();
    }
  }

  @override
  Future<void> close() {
    _detector?.stopListening();
    return super.close();
  }
}
