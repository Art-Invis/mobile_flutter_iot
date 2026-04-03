import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/common/primary_button.dart';

class RegisterForm extends StatefulWidget {
  final bool isLoading;
  const RegisterForm({required this.isLoading, super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _deptController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError, _emailError, _deptError, _passwordError;

  void _handleRegister() {
    setState(() {
      _nameError = _emailError = _deptError = _passwordError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final dept = _deptController.text.trim();
    final password = _passwordController.text.trim();
    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Required');
      hasError = true;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Invalid email');
      hasError = true;
    }
    if (dept.isEmpty) {
      setState(() => _deptError = 'Required');
      hasError = true;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Min 6 chars');
      hasError = true;
    }

    if (hasError) return;

    final newUser = UserModel(
      fullName: name,
      email: email,
      password: password,
      department: dept,
    );

    context.read<AuthCubit>().register(newUser);
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
            hintText: 'Department (e.g., KSA)',
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
          if (widget.isLoading)
            const CircularProgressIndicator(color: Color(0xFF4ADE80))
          else
            PrimaryButton(
              text: 'INITIALIZE ACCOUNT',
              onPressed: _handleRegister,
            ),
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
