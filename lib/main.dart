import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/cubits/device_cubit.dart';
import 'package:mobile_flutter_iot/cubits/mqtt_cubit.dart'; // ОНОВЛЕНО
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/screens/auth/login_screen.dart';
import 'package:mobile_flutter_iot/screens/auth/register_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/screens/main/main_wrapper.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final localUserRepository = LocalUserRepository();
  final connectivityService = ConnectivityService();

  final token = await const FlutterSecureStorage().read(key: 'access_token');
  final initialRoute = token != null ? '/main' : '/login';

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: localUserRepository),
        RepositoryProvider.value(value: connectivityService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              apiService: context.read<ApiService>(),
              userRepository: context.read<LocalUserRepository>(),
            )..checkAuth(),
          ),
          BlocProvider(
            create: (context) => DeviceCubit(
              apiService: context.read<ApiService>(),
              localRepo: context.read<LocalUserRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MqttCubit(
              apiService: context.read<ApiService>(),
            ),
          ),
        ],
        child: SmartWorkspaceApp(initialRoute: initialRoute),
      ),
    ),
  );
}

class SmartWorkspaceApp extends StatelessWidget {
  final String initialRoute;
  const SmartWorkspaceApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Workspace Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF38BDF8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF4ADE80),
          error: Color(0xFFF87171),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainWrapper(),
        '/details': (context) => const DetailsScreen(),
      },
    );
  }
}
