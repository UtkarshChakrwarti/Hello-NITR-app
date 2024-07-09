import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class OtpInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const OtpInput({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 24, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor),
      ),
    );

    return Pinput(
      length: 6,
      autofocus: true,
      onChanged: onChanged,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          border: Border.all(color: AppColors.primaryColor, width: 2),
        ),
      ),
      submittedPinTheme: defaultPinTheme,
    );
  }
}
