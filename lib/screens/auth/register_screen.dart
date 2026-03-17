import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _deptController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userRepository = LocalUserRepository();

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final dept = _deptController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || dept.isEmpty || password.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    final newUser = UserModel(
      fullName: name,
      email: email,
      password: password,
      department: dept,
    );

    await _userRepository.saveUser(newUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful! Please login.')),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlurBlob(
            alignment: Alignment.topLeft,
            translation: const Offset(-0.2, -0.3),
            color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
            size: 280,
          ),
          BlurBlob(
            alignment: Alignment.bottomRight,
            translation: const Offset(0.3, 0.2),
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            size: 320,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTopIcon(),
                    const SizedBox(height: 30),
                    const Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildTopIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.03),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.app_registration_rounded,
        size: 60,
        color: Color(0xFF4ADE80),
      ),
    );
  }

  Widget _buildForm() {
    return GlassCard(
      child: Column(
        children: [
          GlassInput(
            hintText: 'Full Name',
            icon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Email Address',
            icon: Icons.alternate_email,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Department (e.g., KSA, IoT)',
            icon: Icons.business_center,
            controller: _deptController,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Access Password',
            icon: Icons.lock_open,
            isPassword: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: 'CREATE ACCESS KEY', onPressed: _handleRegister),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'RETURN TO ENTRANCE',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
