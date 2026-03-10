import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/screens/auth/login_screen.dart';
import 'package:mobile_flutter_iot/screens/auth/register_screen.dart';

void main() {
  runApp(const SmartWorkspaceApp());
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

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.white70),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
