import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isOffline;
  AuthAuthenticated(this.user, {this.isOffline = false});
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistered extends AuthState {
  final bool isOffline;
  AuthRegistered({this.isOffline = false});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final ApiService apiService;
  final LocalUserRepository userRepository;

  final _storage = const FlutterSecureStorage();

  AuthCubit({required this.apiService, required this.userRepository})
      : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());

    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final user = await userRepository.getUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
          return;
        }
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final result = await apiService.login(email, password);

      if (result != null && result['token'] != null) {
        final token = result['token'].toString();
        final userData = result['user'] as Map<String, dynamic>;

        await _storage.write(key: 'access_token', value: token);

        final user = UserModel(
          fullName: userData['fullName']?.toString() ?? 'Unknown',
          email: userData['email']?.toString() ?? email,
          password: password,
          department: userData['department']?.toString() ?? 'Unknown',
        );
        await userRepository.saveUser(user);

        emit(AuthAuthenticated(user));
        return;
      }
    } catch (e) {
      //
    }

    final localUser = await userRepository.getUser();

    if (localUser != null &&
        localUser.email == email &&
        localUser.password == password) {
      await _storage.write(key: 'access_token', value: 'offline_mode_token');
      emit(AuthAuthenticated(localUser, isOffline: true));
    } else {
      emit(AuthError('Login Failed: Invalid credentials or Server Offline'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(UserModel user) async {
    emit(AuthLoading());
    try {
      final success = await apiService.register(user);
      if (success) {
        await userRepository.saveUser(user);
        emit(AuthRegistered());
      } else {
        emit(AuthError('Server error or email already exists.'));
      }
    } catch (e) {
      await userRepository.saveUser(user);
      emit(AuthRegistered(isOffline: true));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _storage.delete(key: 'access_token');
    await userRepository.deleteUser();
    emit(AuthUnauthenticated());
  }
}
