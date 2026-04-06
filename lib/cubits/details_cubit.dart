import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class DetailsState {
  final bool isSavingSnapshot;
  final bool isManualControlOn;
  final String? currentValue;
  final String? customIp;
  final String? alertMessage;
  final bool isError;
  final bool isDeleted;

  const DetailsState({
    this.isSavingSnapshot = false,
    this.isManualControlOn = true,
    this.currentValue,
    this.customIp,
    this.alertMessage,
    this.isError = false,
    this.isDeleted = false,
  });

  DetailsState copyWith({
    bool? isSavingSnapshot,
    bool? isManualControlOn,
    String? currentValue,
    String? customIp,
    String? alertMessage,
    bool? isError,
    bool? isDeleted,
  }) {
    return DetailsState(
      isSavingSnapshot: isSavingSnapshot ?? this.isSavingSnapshot,
      isManualControlOn: isManualControlOn ?? this.isManualControlOn,
      currentValue: currentValue ?? this.currentValue,
      customIp: customIp ?? this.customIp,
      alertMessage: alertMessage,
      isError: isError ?? this.isError,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class DetailsCubit extends Cubit<DetailsState> {
  final ApiService apiService;
  final LocalUserRepository userRepository;

  DetailsCubit({required this.apiService, required this.userRepository})
      : super(const DetailsState());

  Future<void> saveSnapshot(String id, String value) async {
    emit(state.copyWith(isSavingSnapshot: true));
    final success = await apiService.saveLog(id, value);

    if (success) {
      emit(
        state.copyWith(
          isSavingSnapshot: false,
          alertMessage: 'Snapshot saved to cloud! 📸',
          isError: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isSavingSnapshot: false,
          alertMessage: 'Failed to save snapshot. Check connection.',
          isError: true,
        ),
      );
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final success = await apiService.deleteDevice(deviceId);
    if (success) {
      final devices = await userRepository.getDevices();
      devices.removeWhere((d) => d.id == deviceId);
      await userRepository.saveDevices(devices);
      emit(
        state.copyWith(
          isDeleted: true,
          alertMessage: 'Device deleted from cloud!',
        ),
      );
    } else {
      emit(
        state.copyWith(
          alertMessage: 'Failed to delete (Check connection)',
          isError: true,
        ),
      );
    }
  }

  Future<void> updateValue(String id, String newValue) async {
    final devices = await userRepository.getDevices();
    final index = devices.indexWhere((d) => d.id == id);

    if (index != -1) {
      devices[index].value = newValue;
      await apiService.updateDevice(devices[index]);
      await userRepository.saveDevices(devices);
      emit(
        state.copyWith(
          currentValue: newValue,
          alertMessage: 'Value updated!',
        ),
      );
    }
  }

  void updateIp(String newIp) {
    emit(
      state.copyWith(
        customIp: newIp,
        alertMessage: 'Reconnecting to $newIp...',
      ),
    );
  }

  void toggleManualControl(bool value) {
    emit(state.copyWith(isManualControlOn: value));
  }
}
