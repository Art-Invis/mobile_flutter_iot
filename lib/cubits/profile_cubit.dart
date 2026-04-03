import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class ProfileState {
  final UserModel? user;
  final bool notifications;
  final bool darkMode;
  final String? alertMessage;
  final bool isError;
  final bool isAccountDeleted;

  const ProfileState({
    this.user,
    this.notifications = true,
    this.darkMode = true,
    this.alertMessage,
    this.isError = false,
    this.isAccountDeleted = false,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? notifications,
    bool? darkMode,
    String? alertMessage,
    bool? isError,
    bool? isAccountDeleted,
  }) {
    return ProfileState(
      user: user ?? this.user,
      notifications: notifications ?? this.notifications,
      darkMode: darkMode ?? this.darkMode,
      alertMessage: alertMessage,
      isError: isError ?? this.isError,
      isAccountDeleted: isAccountDeleted ?? this.isAccountDeleted,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  final ApiService apiService;
  final LocalUserRepository userRepository;

  ProfileCubit({required this.apiService, required this.userRepository})
      : super(const ProfileState()) {
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await userRepository.getUser();
    emit(state.copyWith(user: user));
  }

  void toggleNotifications(bool value) =>
      emit(state.copyWith(notifications: value));
  void toggleDarkMode(bool value) => emit(state.copyWith(darkMode: value));

  Future<void> updateField(String field, String newValue) async {
    final user = state.user;
    if (user == null) return;

    final updatedUser = UserModel(
      fullName: field == 'Name' ? newValue : user.fullName,
      email: field == 'Email' ? newValue : user.email,
      password: user.password,
      department: field == 'Department' ? newValue : user.department,
    );

    final success = await apiService.updateUserProfile(updatedUser);
    if (success) {
      await userRepository.saveUser(updatedUser);
      emit(
        state.copyWith(
          user: updatedUser,
          alertMessage: '$field updated successfully!',
        ),
      );
    } else {
      emit(
        state.copyWith(
          alertMessage: 'Failed to update $field (Check connection/email)',
          isError: true,
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    final success = await apiService.deleteAccount();
    if (success) {
      await userRepository.deleteUser();
      emit(
        state.copyWith(
          isAccountDeleted: true,
          alertMessage: 'Cloud Account Destroyed.',
        ),
      );
    } else {
      emit(
        state.copyWith(
          alertMessage: 'Failed to delete account.',
          isError: true,
        ),
      );
    }
  }
}
