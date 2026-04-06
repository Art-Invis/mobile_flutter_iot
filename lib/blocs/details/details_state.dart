import 'package:equatable/equatable.dart';

class DetailsState extends Equatable {
  final String? currentValue;
  final String? customIp;
  final bool isManualControlOn;
  final bool isSavingSnapshot;
  final String? alertMessage;
  final bool isError;
  final bool isDeleted;

  const DetailsState({
    this.currentValue,
    this.customIp,
    this.isManualControlOn = false,
    this.isSavingSnapshot = false,
    this.alertMessage,
    this.isError = false,
    this.isDeleted = false,
  });

  DetailsState copyWith({
    String? currentValue,
    String? customIp,
    bool? isManualControlOn,
    bool? isSavingSnapshot,
    String? alertMessage,
    bool? isError,
    bool? isDeleted,
    bool clearAlert = false,
  }) {
    return DetailsState(
      currentValue: currentValue ?? this.currentValue,
      customIp: customIp ?? this.customIp,
      isManualControlOn: isManualControlOn ?? this.isManualControlOn,
      isSavingSnapshot: isSavingSnapshot ?? this.isSavingSnapshot,
      alertMessage: clearAlert ? null : (alertMessage ?? this.alertMessage),
      isError: !clearAlert && (isError ?? this.isError),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        currentValue,
        customIp,
        isManualControlOn,
        isSavingSnapshot,
        alertMessage,
        isError,
        isDeleted,
      ];
}
