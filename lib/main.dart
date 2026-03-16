import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/screens/auth/login_screen.dart';
import 'package:mobile_flutter_iot/screens/auth/register_screen.dart';
import 'package:mobile_flutter_iot/screens/home/details_screen.dart';
import 'package:mobile_flutter_iot/screens/main/main_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(SmartWorkspaceApp(isLoggedIn: isLoggedIn));
}

class SmartWorkspaceApp extends StatelessWidget {
  final bool isLoggedIn;
  const SmartWorkspaceApp({required this.isLoggedIn, super.key});

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

      home: isLoggedIn ? const MainWrapper() : const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainWrapper(),
        '/details': (context) => const DetailsScreen(),
      },
    );
  }
}
