import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/profile/profile_header.dart';
import 'package:mobile_flutter_iot/widgets/profile/profile_settings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => ProfileCubit(
        apiService: context.read<ApiService>(),
        userRepository: context.read<LocalUserRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state.alertMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.alertMessage!),
                    backgroundColor:
                        state.isError ? Colors.orange : const Color(0xFF4ADE80),
                  ),
                );
              }
              if (state.isAccountDeleted) {
                context.read<AuthCubit>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              final authState = context.watch<AuthCubit>().state;
              final isLoggedIn = authState is AuthAuthenticated;

              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    BlurBlob(
                      alignment: Alignment.topRight,
                      translation: const Offset(0.3, -0.3),
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                      size: size.width * 0.7,
                    ),
                    BlurBlob(
                      alignment: Alignment.bottomLeft,
                      translation: const Offset(-0.3, 0.3),
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
                      size: size.width * 0.8,
                    ),
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        const SliverAppBar(
                          expandedHeight: 100,
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              'USER PROFILE',
                              style: TextStyle(
                                letterSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              ProfileHeader(state: state),
                              const SizedBox(height: 32),
                              ProfileSettings(
                                state: state,
                                isLoggedIn: isLoggedIn,
                              ),
                              const SizedBox(height: 40),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
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
// import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
// import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';
// import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
// import 'package:mobile_flutter_iot/services/api_service.dart';
// import 'package:mobile_flutter_iot/widgets/profile/emergency_wrapper.dart'; // НОВИЙ ІМПОРТ

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ProfileCubit(
//         apiService: context.read<ApiService>(),
//         userRepository: context.read<LocalUserRepository>(),
//       ),
//       child: Builder(
//         builder: (context) {
//           return BlocConsumer<ProfileCubit, ProfileState>(
//             listener: (context, state) {
//               if (state.alertMessage != null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(state.alertMessage!),
//                     backgroundColor:
//                      state.isError ? Colors.orange : const Color(0xFF4ADE80),
//                   ),
//                 );
//               }
//               if (state.isAccountDeleted) {
//                 context.read<AuthCubit>().logout();
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, '/login', (route) => false);
//               }
//             },
//             builder: (context, state) {
//               final authState = context.watch<AuthCubit>().state;
//               final isLoggedIn = authState is AuthAuthenticated;

//               return EmergencyOverrideWrapper(
//                 profileState: state,
//                 isLoggedIn: isLoggedIn,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
