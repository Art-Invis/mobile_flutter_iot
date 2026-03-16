import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlurBlob(
            alignment: Alignment.topRight,
            translation: const Offset(0.2, -0.3),
            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
            size: 250,
          ),
          BlurBlob(
            alignment: Alignment.bottomLeft,
            translation: const Offset(-0.3, 0.3),
            color: const Color(0xFF4ADE80).withValues(alpha: 0.1),
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
                    _buildLoginForm(context),
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

  Widget _buildLoginForm(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const GlassInput(
            hintText: 'System ID / Email',
            icon: Icons.alternate_email,
          ),
          const SizedBox(height: 16),
          const GlassInput(
            hintText: 'Password',
            icon: Icons.fingerprint,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'INITIALIZE LOGIN',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);

              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/main');
              }
            },
          ),
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
