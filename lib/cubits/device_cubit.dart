import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:shake/shake.dart';

abstract class DeviceState {}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<DeviceModel> devices;
  final String? alertMessage;
  final bool isError;

  DeviceLoaded(this.devices, {this.alertMessage, this.isError = false});
}

class DeviceCubit extends Cubit<DeviceState> {
  final ApiService apiService;
  final LocalUserRepository localRepo;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  ShakeDetector? _shakeDetector;

  DeviceCubit({required this.apiService, required this.localRepo})
      : super(DeviceInitial()) {
    _initListeners();
    loadDevices();
  }

  void _initListeners() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasNet = !results.contains(ConnectivityResult.none);
      if (hasNet && state is DeviceLoaded) {
        loadDevices(alertMessage: 'ONLINE: Connection restored! Syncing...');
      } else if (!hasNet) {
        loadDevices(
          alertMessage: 'OFFLINE: Check your Wi-Fi connection',
          isError: true,
        );
      }
    });

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) => loadDevices(alertMessage: 'SHAKE: Data refreshed'),
      shakeThresholdGravity: 1.5,
    );
  }

  Future<void> loadDevices({String? alertMessage, bool isError = false}) async {
    if (state is! DeviceLoaded) emit(DeviceLoading());

    final hasNet = !(await Connectivity().checkConnectivity())
        .contains(ConnectivityResult.none);

    if (!hasNet) {
      final localDevices = await localRepo.getDevices();
      emit(
        DeviceLoaded(
          localDevices,
          alertMessage: alertMessage ?? 'Offline Mode',
          isError: true,
        ),
      );
      return;
    }

    try {
      final devices = await apiService.fetchDevices();
      if (devices != null) {
        await localRepo.saveDevices(devices);
        emit(DeviceLoaded(devices, alertMessage: alertMessage));
      } else {
        throw Exception('API returned null');
      }
    } catch (e) {
      final localDevices = await localRepo.getDevices();
      emit(
        DeviceLoaded(
          localDevices,
          alertMessage: 'Sync failed. Using local data.',
          isError: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    _shakeDetector?.stopListening();
    return super.close();
  }
}
