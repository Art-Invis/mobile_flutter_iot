import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/common/primary_button.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  const LoginForm({required this.isLoading, super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(email, password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          if (widget.isLoading)
            const CircularProgressIndicator(color: Color(0xFF38BDF8))
          else
            PrimaryButton(
              text: 'INITIALIZE LOGIN',
              onPressed: _handleLogin,
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
