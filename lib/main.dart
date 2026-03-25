import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/providers/auth_provider.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/screens/auth/login_screen.dart';
import 'package:mobile_flutter_iot/screens/auth/register_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/screens/main/main_wrapper.dart';
import 'package:mobile_flutter_iot/services/connectivity_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MqttProvider()),
      ],
      child: const SmartWorkspaceApp(),
    ),
  );
}

class SmartWorkspaceApp extends StatelessWidget {
  const SmartWorkspaceApp({super.key});

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
      home: const RootHandler(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainWrapper(),
        '/details': (context) => const DetailsScreen(),
      },
    );
  }
}

class RootHandler extends StatefulWidget {
  const RootHandler({super.key});

  @override
  State<RootHandler> createState() => _RootHandlerState();
}

class _RootHandlerState extends State<RootHandler> {
  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await ConnectivityService().hasConnection();

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!auth.isLoggedIn) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline Mode: Session loaded from cache.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('System Online. Syncing data...'),
            backgroundColor: Color(0xFF4ADE80),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const MainWrapper() : const LoginScreen();
  }
}
