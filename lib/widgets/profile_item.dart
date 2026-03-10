import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSwitch;
  final String? trailingText;
  final bool value;
  final void Function(bool)? onChanged;

  const ProfileMenuItem({
    required this.icon, required this.title, super.key,
    this.isSwitch = false,
    this.trailingText,
    this.value = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF38BDF8)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: isSwitch
          ? Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF38BDF8),
            )
          : Text(
              trailingText ?? '',
              style: const TextStyle(color: Colors.white38),
            ),
    );
  }
}
