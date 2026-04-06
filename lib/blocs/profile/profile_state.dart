import 'package:equatable/equatable.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final UserModel? user;
  final bool notifications;
  final bool darkMode;
  final String? alertMessage;
  final bool isError;
  final bool isAccountDeleted;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.notifications = true,
    this.darkMode = true,
    this.alertMessage,
    this.isError = false,
    this.isAccountDeleted = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    bool? notifications,
    bool? darkMode,
    String? alertMessage,
    bool? isError,
    bool? isAccountDeleted,
    bool clearAlert = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      notifications: notifications ?? this.notifications,
      darkMode: darkMode ?? this.darkMode,
      alertMessage: clearAlert ? null : (alertMessage ?? this.alertMessage),
      isError: !clearAlert && (isError ?? this.isError),
      isAccountDeleted: isAccountDeleted ?? this.isAccountDeleted,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        user,
        notifications,
        darkMode,
        alertMessage,
        isError,
        isAccountDeleted,
      ];
}
