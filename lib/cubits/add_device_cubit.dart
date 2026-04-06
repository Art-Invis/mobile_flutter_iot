import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class AddDeviceState {
  final Color selectedColor;
  final IconData selectedIcon;
  final bool isLoading;
  final bool? isSuccess;
  final String? errorMessage;

  const AddDeviceState({
    required this.selectedColor,
    required this.selectedIcon,
    this.isLoading = false,
    this.isSuccess,
    this.errorMessage,
  });

  AddDeviceState copyWith({
    Color? selectedColor,
    IconData? selectedIcon,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AddDeviceState(
      selectedColor: selectedColor ?? this.selectedColor,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class AddDeviceCubit extends Cubit<AddDeviceState> {
  final ApiService apiService;

  AddDeviceCubit({
    required this.apiService,
    required Color initialColor,
    required IconData initialIcon,
  }) : super(
          AddDeviceState(
            selectedColor: initialColor,
            selectedIcon: initialIcon,
          ),
        );

  void selectColor(Color color) {
    emit(state.copyWith(selectedColor: color));
  }

  void selectIcon(IconData icon) {
    emit(state.copyWith(selectedIcon: icon));
  }

  Future<void> saveDevice(DeviceModel device, bool isNew) async {
    emit(state.copyWith(isLoading: true));

    try {
      final success = isNew
          ? await apiService.addDevice(device)
          : await apiService.updateDevice(device);

      if (success) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: 'API Error: Saved to local cache only.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Connection failed.',
        ),
      );
    }
  }
}
