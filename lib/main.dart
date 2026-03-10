import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/screens/auth/login_screen.dart';
import 'package:mobile_flutter_iot/screens/auth/register_screen.dart';
import 'package:mobile_flutter_iot/screens/main/main_wrapper.dart'; 

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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainWrapper(),
      },
    );
  }
}

// Заглушка
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: Center(child: Text('$title Module coming soon...')),
    );
  }
}
