import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/widgets/profile/emergency_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

              return EmergencyOverrideWrapper(
                profileState: state,
                isLoggedIn: isLoggedIn,
              );
            },
          );
        },
      ),
    );
  }
}
