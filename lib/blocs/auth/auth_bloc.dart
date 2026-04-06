import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter_iot/blocs/auth/auth_event.dart';
import 'package:mobile_flutter_iot/blocs/auth/auth_state.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final LocalUserRepository userRepository;
  final _storage = const FlutterSecureStorage();

  AuthBloc({
    required this.apiService,
    required this.userRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await apiService.login(event.email, event.password);

      if (result != null && result['token'] != null) {
        final token = result['token'].toString();
        await _storage.write(key: 'access_token', value: token);

        if (result['user'] != null) {
          final userData = result['user'] as Map<String, dynamic>;

          final user = UserModel(
            fullName: userData['fullName']?.toString() ?? 'Unknown',
            email: userData['email']?.toString() ?? event.email,
            password: event.password, // Беремо з івенту
            department: userData['department']?.toString() ?? 'IoT',
          );
          await userRepository.saveUser(user);
        }

        emit(AuthAuthenticated());
        return;
      }
    } catch (e) {
      //
    }

    final localUser = await userRepository.getUser();

    if (localUser != null &&
        localUser.email == event.email &&
        localUser.password == event.password) {
      await _storage.write(key: 'access_token', value: 'offline_mode_token');
      emit(AuthAuthenticated());
    } else {
      emit(
        const AuthError(
          'Login Failed: Invalid credentials or Server Offline',
        ),
      );
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final userToSave = UserModel(
      fullName: event.name,
      email: event.email,
      password: event.password,
      department: 'IoT',
    );

    try {
      final success = await apiService.register(userToSave);

      if (success) {
        add(AuthLoginRequested(email: event.email, password: event.password));
      } else {
        emit(const AuthError('Помилка реєстрації. Можливо, email вже існує.'));
      }
    } catch (e) {
      await userRepository.saveUser(userToSave);
      await _storage.write(key: 'access_token', value: 'offline_mode_token');
      emit(AuthAuthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    await _storage.delete(key: 'access_token');
    await userRepository.deleteUser();

    emit(AuthUnauthenticated());
  }
}
