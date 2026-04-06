import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/utils/login_form.dart';
import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _showStatusMessage(context, 'Access Granted. Welcome back!');
            Navigator.pushReplacementNamed(context, '/main');
          } else if (state is AuthError) {
            _showStatusMessage(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
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
                          'IOT NODE TERMINAL v2.0',
                          style: TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                        const SizedBox(height: 40),
                        LoginForm(isLoading: isLoading),
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
}

/* ============================================================
[ADVANCED ARCHITECTURE OPTION: BLoC IMPLEMENTATION]
Щоб переключити екран на BLoC, розкоментуйте код нижче 
та закоментуйте секцію з Cubit вище.
============================================================*/

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/auth/auth_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/auth/auth_state.dart';
// import 'package:mobile_flutter_iot/utils/login_form.dart';
// import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   void _showStatusMessage(
//     BuildContext context,
//     String message, {
//     bool isError = false,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//        backgroundColor: isError ? Colors.redAccent : const Color(0xFF4ADE80),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthAuthenticated) {
//             _showStatusMessage(context, 'Access Granted. Welcome back!');
//             Navigator.pushReplacementNamed(context, '/main');
//           } else if (state is AuthError) {
//             _showStatusMessage(context, state.message, isError: true);
//           }
//         },
//         builder: (context, state) {
//           final isLoading = state is AuthLoading;

//           return Stack(
//             children: [
//               BlurBlob(
//                 alignment: Alignment.topRight,
//                 translation: const Offset(0.2, -0.3),
//                 color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
//                 size: 250,
//               ),
//               BlurBlob(
//                 alignment: Alignment.bottomLeft,
//                 translation: const Offset(-0.3, 0.3),
//                 color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
//                 size: 300,
//               ),
//               SafeArea(
//                 child: Center(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: Column(
//                       children: [
//                         _buildLogo(),
//                         const SizedBox(height: 30),
//                         const Text(
//                           'SMART WORKSPACE',
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 3,
//                           ),
//                         ),
//                         const Text(
//                           'IOT NODE TERMINAL v2.0',
//                        style: TextStyle(color: Colors.white30, fontSize: 12),
//                         ),
//                         const SizedBox(height: 40),
//                         LoginForm(isLoading: isLoading),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLogo() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
//           width: 2,
//         ),
//       ),
//    child: const Icon(Icons.hub_outlined, size: 60, color: Color(0xFF38BDF8)),
//     );
//   }
// }
