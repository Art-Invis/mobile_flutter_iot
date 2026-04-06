import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/blocs/device/device_event.dart';
import 'package:mobile_flutter_iot/blocs/device/device_state.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final ApiService apiService;
  final LocalUserRepository localRepo;

  DeviceBloc({
    required this.apiService,
    required this.localRepo,
  }) : super(DeviceInitial()) {
    on<DeviceFetchRequested>(_onFetchRequested);
    on<DeviceAddRequested>(_onAddRequested);
    on<DeviceUpdateRequested>(_onUpdateRequested);
    on<DeviceDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onFetchRequested(
    DeviceFetchRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    try {
      final devices = await apiService.fetchDevices();

      if (devices != null) {
        await localRepo.saveDevices(devices);
        emit(DeviceLoaded(devices));
      } else {
        _loadFromCacheFallback(emit);
      }
    } catch (e) {
      _loadFromCacheFallback(emit);
    }
  }

  Future<void> _onAddRequested(
    DeviceAddRequested event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      final success = await apiService.addDevice(event.device);
      if (success) {
        add(DeviceFetchRequested());
      } else {
        emit(const DeviceError('Failed to add device to cloud.'));
      }
    } catch (e) {
      emit(DeviceError('Connection error: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    DeviceUpdateRequested event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      final success = await apiService.updateDevice(event.device);
      if (success) {
        add(DeviceFetchRequested());
      } else {
        emit(const DeviceError('Failed to update device.'));
      }
    } catch (e) {
      emit(DeviceError('Connection error: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    DeviceDeleteRequested event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      final success = await apiService.deleteDevice(event.deviceId);
      if (success) {
        add(DeviceFetchRequested());
      } else {
        emit(const DeviceError('Failed to delete device.'));
      }
    } catch (e) {
      emit(DeviceError('Connection error: $e'));
    }
  }

  Future<void> _loadFromCacheFallback(Emitter<DeviceState> emit) async {
    try {
      final localDevices = await localRepo.getDevices();
      if (localDevices.isNotEmpty) {
        emit(DeviceLoaded(localDevices, isOffline: true));
      } else {
        emit(const DeviceError('No internet and no cached data available.'));
      }
    } catch (_) {
      emit(const DeviceError('Critical error reading local cache.'));
    }
  }
}
