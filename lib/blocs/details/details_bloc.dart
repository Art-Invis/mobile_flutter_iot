import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/blocs/details/details_event.dart';
import 'package:mobile_flutter_iot/blocs/details/details_state.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final ApiService apiService;
  final LocalUserRepository userRepository;

  DetailsBloc({
    required this.apiService,
    required this.userRepository,
  }) : super(const DetailsState(isManualControlOn: true)) {
    on<DetailsToggleManualControlRequested>((event, emit) {
      emit(state.copyWith(isManualControlOn: event.isOn));
    });

    on<DetailsUpdateIpRequested>((event, emit) {
      emit(
        state.copyWith(
          customIp: event.newIp,
          alertMessage: 'Reconnecting to ${event.newIp}...',
        ),
      );
    });

    on<DetailsUpdateValueRequested>(_onUpdateValueRequested);
    on<DetailsSaveSnapshotRequested>(_onSaveSnapshotRequested);
    on<DetailsDeleteDeviceRequested>(_onDeleteDeviceRequested);
  }

  Future<void> _onUpdateValueRequested(
    DetailsUpdateValueRequested event,
    Emitter<DetailsState> emit,
  ) async {
    final devices = await userRepository.getDevices();
    emit(
      state.copyWith(
        currentValue: event.newValue,
        alertMessage: 'Value updated!',
      ),
    );

    final index = devices.indexWhere((d) => d.value == state.currentValue);
    if (index != -1) {
      await apiService.updateDevice(devices[index]);
      await userRepository.saveDevices(devices);
    }
  }

  Future<void> _onDeleteDeviceRequested(
    DetailsDeleteDeviceRequested event,
    Emitter<DetailsState> emit,
  ) async {
    final success = await apiService.deleteDevice(event.deviceId);
    if (success) {
      final devices = await userRepository.getDevices();
      devices.removeWhere((d) => d.id == event.deviceId);
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

  Future<void> _onSaveSnapshotRequested(
    DetailsSaveSnapshotRequested event,
    Emitter<DetailsState> emit,
  ) async {
    emit(state.copyWith(isSavingSnapshot: true));
    final success = await apiService.saveLog(event.sensorId, event.value);
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
}
