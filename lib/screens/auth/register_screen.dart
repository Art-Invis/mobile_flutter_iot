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

  String? _nameError;
  String? _emailError;
  String? _deptError;
  String? _passwordError;

  void _handleRegister() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _deptError = null;
      _passwordError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final dept = _deptController.text.trim();
    final password = _passwordController.text.trim();

    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter your full name');
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email address is required');
      hasError = true;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Invalid email format (missing @ or .)');
      hasError = true;
    }

    if (dept.isEmpty) {
      setState(() => _deptError = 'Specify your university department');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Security password is required');
      hasError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }

    if (hasError) return;

    final newUser = UserModel(
      fullName: name,
      email: email,
      password: password,
      department: dept,
    );

    await _userRepository.saveUser(newUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Key Created! You can now log in.'),
          backgroundColor: Color(0xFF4ADE80),
        ),
      );
      Navigator.pop(context);
    }
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTopIcon(),
                    const SizedBox(height: 30),
                    const Text(
                      'CREATE ACCESS KEY',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register in the IoT System',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 20),
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
          color: const Color(0xFF4ADE80).withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.app_registration_rounded,
        size: 50,
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
            errorText: _nameError,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Email Address',
            icon: Icons.alternate_email,
            controller: _emailController,
            errorText: _emailError,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Department (e.g., KSA, IoT)',
            icon: Icons.business_center_outlined,
            controller: _deptController,
            errorText: _deptError,
          ),
          const SizedBox(height: 16),
          GlassInput(
            hintText: 'Access Password',
            icon: Icons.lock_open_rounded,
            isPassword: true,
            controller: _passwordController,
            errorText: _passwordError,
          ),
          const SizedBox(height: 32),
          PrimaryButton(text: 'INITIALIZE ACCOUNT', onPressed: _handleRegister),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ALREADY HAVE A KEY? RETURN',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
