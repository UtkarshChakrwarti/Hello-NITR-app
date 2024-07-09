import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final FocusNode focusNode;
  final VoidCallback? onVisibilityToggle;

  const CustomTextField({super.key, 
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    required this.focusNode,
    this.onVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText && hintText == "Password" ? obscureText : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        suffixIcon: hintText == "Password"
            ? IconButton(
                icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.primaryColor),
                onPressed: onVisibilityToggle,
              )
            : null,
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black26, width: 2.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0)),
      ),
    );
  }
}
