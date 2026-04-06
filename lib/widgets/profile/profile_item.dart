import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSwitch;
  final String? trailingText;
  final bool value;
  final void Function(bool)? onChanged;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    super.key,
    this.isSwitch = false,
    this.trailingText,
    this.value = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: isSwitch ? null : onTap,
      leading: Icon(icon, color: const Color(0xFF38BDF8)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: isSwitch
          ? Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF38BDF8),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailingText ?? '',
                  style: const TextStyle(color: Colors.white38),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white10,
                    size: 20,
                  ),
              ],
            ),
    );
  }
}
