import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';
import 'package:mobile_flutter_iot/utils/profile_dialogs.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/profile/profile_item.dart';

class ProfileSettings extends StatelessWidget {
  final ProfileState state;
  final bool isLoggedIn;

  const ProfileSettings({
    required this.state,
    required this.isLoggedIn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Row(
            children: [
              Icon(
                isLoggedIn
                    ? Icons.verified_user_rounded
                    : Icons.shield_moon_outlined,
                color:
                    isLoggedIn ? const Color(0xFF4ADE80) : Colors.orangeAccent,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security Protocol',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isLoggedIn
                        ? 'Persistent Session: Active'
                        : 'Session Encryption: Local Only',
                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'PREFERENCES',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              ProfileMenuItem(
                icon: Icons.notifications_active_outlined,
                title: 'System Alerts',
                isSwitch: true,
                value: state.notifications,
                onChanged: (v) =>
                    context.read<ProfileCubit>().toggleNotifications(v),
              ),
              const Divider(color: Colors.white10),
              ProfileMenuItem(
                icon: Icons.palette_outlined,
                title: 'OLED Dark Mode',
                isSwitch: true,
                value: state.darkMode,
                onChanged: (v) =>
                    context.read<ProfileCubit>().toggleDarkMode(v),
              ),
              const Divider(color: Colors.white10),
              ProfileMenuItem(
                icon: Icons.hub_outlined,
                title: 'Department Unit',
                trailingText: state.user?.department ?? '...',
                onTap: () => ProfileDialogs.showEditField(
                  context,
                  'Department',
                  state.user?.department ?? '',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'ACCOUNT ACTIONS',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            onTap: () => ProfileDialogs.showLogout(context),
            leading: const Icon(Icons.logout, color: Color(0xFFF87171)),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFF87171),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => ProfileDialogs.showDeleteAccount(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFF87171).withValues(alpha: 0.3),
              ),
              color: const Color(0xFFF87171).withValues(alpha: 0.05),
            ),
            child: const Center(
              child: Text(
                'DELETE ACCOUNT',
                style: TextStyle(
                  color: Color(0xFFF87171),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
