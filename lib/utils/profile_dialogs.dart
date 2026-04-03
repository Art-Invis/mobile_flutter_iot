import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';

class ProfileDialogs {
  static void showLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'System Termination',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child:
                const Text('LOGOUT', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  static void showDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF87171)),
            SizedBox(width: 10),
            Text('System Purge', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will permanently erase your encryption keys, cloud data,'
          'and local profile. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF87171).withValues(alpha: 0.2),
              foregroundColor: const Color(0xFFF87171),
              side: const BorderSide(color: Color(0xFFF87171)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('CONFIRM PURGE'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<ProfileCubit>().deleteAccount();
    }
  }

  static void showEditField(
    BuildContext context,
    String fieldTitle,
    String currentValue,
  ) async {
    final controller = TextEditingController(text: currentValue);
    final cubit = context.read<ProfileCubit>();

    final newValue = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Update $fieldTitle',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $fieldTitle',
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child:
                const Text('Save', style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty) {
      cubit.updateField(fieldTitle, newValue);
    }
  }
}
