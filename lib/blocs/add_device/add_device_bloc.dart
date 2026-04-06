import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/blocs/add_device/add_device_event.dart';
import 'package:mobile_flutter_iot/blocs/add_device/add_device_state.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class AddDeviceBloc extends Bloc<AddDeviceEvent, AddDeviceState> {
  final ApiService apiService;

  AddDeviceBloc({
    required this.apiService,
    required Color initialColor,
    required IconData initialIcon,
  }) : super(
          AddDeviceState(
            selectedColor: initialColor,
            selectedIcon: initialIcon,
          ),
        ) {
    on<AddDeviceColorChanged>(
      (event, emit) => emit(state.copyWith(selectedColor: event.color)),
    );
    on<AddDeviceIconChanged>(
      (event, emit) => emit(state.copyWith(selectedIcon: event.icon)),
    );
    on<AddDeviceSaveRequested>(_onSaveRequested);
  }

  Future<void> _onSaveRequested(
    AddDeviceSaveRequested event,
    Emitter<AddDeviceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final success = event.isNew
          ? await apiService.addDevice(event.device)
          : await apiService.updateDevice(event.device);

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
