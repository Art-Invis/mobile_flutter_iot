import 'package:flutter/material.dart';

class GlassInput extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? errorText; // Додаємо поле для помилки

  const GlassInput({
    required this.hintText,
    required this.icon,
    this.controller,
    this.errorText, // Додаємо в конструктор
    super.key,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              // Якщо є помилка, робимо рамку червонуватою
              color: errorText != null
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: const Color(0xFF38BDF8), size: 20),
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        // Якщо помилка є, виводимо її маленьким текстом знизу
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
      ],
    );
  }
}
