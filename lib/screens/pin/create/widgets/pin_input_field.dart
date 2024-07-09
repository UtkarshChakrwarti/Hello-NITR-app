import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class PinInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool pinVisible;
  final VoidCallback toggleVisibility;
  final ValueChanged<String>? onChanged;

  const PinInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.pinVisible,
    required this.toggleVisibility,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Pinput(
                length: 4,
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                obscureText: !pinVisible,
                showCursor: true,
                autofillHints: const [], // Disable autofill
                cursor: Container(
                  width: 2,
                  height: 40,
                  color: AppColors.primaryColor,
                ),
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryColor),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: Icon(
                pinVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primaryColor,
              ),
              onPressed: toggleVisibility,
            ),
          ],
        ),
      ],
    );
  }
}
