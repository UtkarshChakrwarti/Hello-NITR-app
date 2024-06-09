import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class PinInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  const PinInputField({super.key, 
    required this.label,
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Pinput(
          length: 4,
          controller: controller,
          focusNode: focusNode,
          autofocus: label == 'Create PIN',
          cursor:
              Container(width: 2, height: 40, color: AppColors.primaryColor),
          defaultPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 22,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: AppColors.primaryColor.withOpacity(0.3), width: 2),
              ),
            ),
          ),
          focusedPinTheme: const PinTheme(
            width: 50,
            height: 50,
            textStyle: TextStyle(
              fontSize: 22,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          submittedPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 22,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: AppColors.primaryColor.withOpacity(0.3), width: 2),
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
