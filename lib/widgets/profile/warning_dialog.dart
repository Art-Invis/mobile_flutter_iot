import 'package:flutter/material.dart';

class PlatformWarningDialog {
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text(
              'Platform Warning',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Hardware flashlight control is currently only supported'
          'on native Android nodes.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'ACKNOWLEDGE',
              style: TextStyle(color: Color(0xFF38BDF8)),
            ),
          ),
        ],
      ),
    );
  }
}
