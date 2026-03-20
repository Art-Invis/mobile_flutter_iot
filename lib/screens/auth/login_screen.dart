import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userRepository = LocalUserRepository();

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showStatusMessage('Please fill in all fields', isError: true);
      return;
    }

    final isValid = await _userRepository.validateCredentials(email, password);

    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        _showStatusMessage('Access Granted. Welcome back!');
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      if (mounted) {
        _showStatusMessage('Invalid email or password', isError: true);
      }
    }
  }

  void _showStatusMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlurBlob(
            alignment: Alignment.topRight,
            translation: const Offset(0.2, -0.3),
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            size: 250,
          ),
          BlurBlob(
            alignment: Alignment.bottomLeft,
            translation: const Offset(-0.3, 0.3),
            color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
            size: 300,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 30),
                    const Text(
                      'SMART WORKSPACE',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const Text(
                      'ELEVATOR MONITOR v1.0',
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                    const SizedBox(height: 40),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: const Icon(Icons.hub_outlined, size: 60, color: Color(0xFF38BDF8)),
    );
  }

  Widget _buildForm() {
    return GlassCard(
      child: Column(
        children: [
          GlassInput(
            hintText: 'System ID / Email',
            icon: Icons.alternate_email,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Password',
            icon: Icons.fingerprint,
            isPassword: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: 'INITIALIZE LOGIN', onPressed: _handleLogin),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text(
              "Don't have an account? Register",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
