import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class OtpInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  OtpInput({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 6,
      autofocus: true,
      cursor: Container(width: 2, height: 40, color: AppColors.primaryColor),
      onChanged: onChanged,
      defaultPinTheme: PinTheme(
        width: 40,
        height: 58,
        textStyle: TextStyle(fontSize: 24, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 40,
        height: 58,
        textStyle: TextStyle(fontSize: 24, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 40,
        height: 58,
        textStyle: TextStyle(fontSize: 24, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryColor, width: 2)),
        ),
      ),
    );
  }
}
