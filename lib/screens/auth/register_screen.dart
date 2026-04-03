import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/utils/register_form.dart';
import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _showStatusMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF4ADE80),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            _showStatusMessage(
              context,
              'Access Key Created in Cloud! You can now log in.',
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            _showStatusMessage(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
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
                        RegisterForm(isLoading: isLoading),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
}
