import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';
import 'package:mobile_flutter_iot/utils/profile_dialogs.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileState state;
  const ProfileHeader({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final name = state.user?.fullName ?? 'Loading...';
    final dept = state.user?.department ?? 'Unknown Department';
    final email = state.user?.email ?? 'no-email@system.io';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF38BDF8).withValues(alpha: 0.5),
                const Color(0xFF4ADE80).withValues(alpha: 0.5),
              ],
            ),
          ),
          child: const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFF0F172A),
            child: CircleAvatar(
              radius: 51,
              backgroundColor: Color(0xFF1E293B),
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => ProfileDialogs.showEditField(context, 'Name', name),
          child: Text(
            name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dept.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4ADE80),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => ProfileDialogs.showEditField(context, 'Email', email),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              email,
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
