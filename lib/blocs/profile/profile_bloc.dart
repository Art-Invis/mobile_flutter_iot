import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/blocs/profile/profile_event.dart';
import 'package:mobile_flutter_iot/blocs/profile/profile_state.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService apiService;
  final LocalUserRepository userRepository;

  ProfileBloc({
    required this.apiService,
    required this.userRepository,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileDeleteAccountRequested>(_onDeleteAccountRequested);

    on<ProfileToggleNotifications>(_onToggleNotifications);
    on<ProfileToggleDarkMode>(_onToggleDarkMode);
    on<ProfileUpdateFieldRequested>(_onUpdateFieldRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearAlert: true));

    try {
      final user = await userRepository.getUser();
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          alertMessage: 'Failed to load profile data',
          isError: true,
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearAlert: true));

    try {
      final success = await apiService.updateUserProfile(event.updatedUser);
      if (success) {
        await userRepository.saveUser(event.updatedUser);
        emit(
          state.copyWith(
            isLoading: false,
            user: event.updatedUser,
            alertMessage: 'Profile updated successfully',
            isError: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            alertMessage: 'Failed to update profile on server',
            isError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          alertMessage: 'Connection error: $e',
          isError: true,
        ),
      );
    }
  }

  Future<void> _onDeleteAccountRequested(
    ProfileDeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearAlert: true));

    try {
      final success = await apiService.deleteAccount();
      if (success) {
        emit(
          state.copyWith(
            isLoading: false,
            isAccountDeleted: true,
            alertMessage: 'System Purge Complete. Account erased.',
            isError: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            alertMessage: 'Failed to initiate System Purge',
            isError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          alertMessage: 'Connection error: $e',
          isError: true,
        ),
      );
    }
  }

  void _onToggleNotifications(
    ProfileToggleNotifications event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(notifications: event.value));
  }

  void _onToggleDarkMode(
    ProfileToggleDarkMode event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(darkMode: event.value));
  }

  Future<void> _onUpdateFieldRequested(
    ProfileUpdateFieldRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    final updatedUser = UserModel(
      fullName: event.fieldTitle == 'Name' ? event.newValue : user.fullName,
      email: event.fieldTitle == 'Email' ? event.newValue : user.email,
      password: user.password,
      department:
          event.fieldTitle == 'Department' ? event.newValue : user.department,
    );

    emit(state.copyWith(isLoading: true, clearAlert: true));
    try {
      final success = await apiService.updateUserProfile(updatedUser);
      if (success) {
        await userRepository.saveUser(updatedUser);
        emit(
          state.copyWith(
            isLoading: false,
            user: updatedUser,
            alertMessage: '${event.fieldTitle} updated successfully!',
            isError: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            alertMessage:
                'Failed to update ${event.fieldTitle} (Check connection/email)',
            isError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          alertMessage: 'Connection error: $e',
          isError: true,
        ),
      );
    }
  }
}
