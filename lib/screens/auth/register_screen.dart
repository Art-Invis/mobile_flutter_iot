import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: BlurBlob(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: BlurBlob(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              size: 320,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.app_registration_rounded,
                      size: 60,
                      color: Color(0xFF4ADE80),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildRegisterForm(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GlassInput(
            hintText: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          const GlassInput(
            hintText: 'Email Address',
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 16),
          const GlassInput(
            hintText: 'Department (e.g., KSA, IoT)',
            icon: Icons.business_center_outlined,
          ),
          const SizedBox(height: 16),
          const GlassInput(
            hintText: 'Access Password',
            icon: Icons.lock_open_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'CREATE ACCESS KEY',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'RETURN TO ENTRANCE',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
