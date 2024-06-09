import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class ResendButton extends StatelessWidget {
  final bool isResendButtonActive;
  final int remainingSeconds;
  final VoidCallback onResend;

  ResendButton({required this.isResendButtonActive, required this.remainingSeconds, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isResendButtonActive ? onResend : null,
      child: Text(
        isResendButtonActive ? "Resend OTP" : "Resend OTP in $remainingSeconds seconds",
        style: TextStyle(
          color: AppColors.primaryColor,
          decoration: TextDecoration.underline,
          fontSize: 16,
        ),
      ),
    );
  }
}
