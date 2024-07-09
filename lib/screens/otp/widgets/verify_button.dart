import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class VerifyButton extends StatelessWidget {
  final bool isOtpComplete;
  final VoidCallback? onPressed;

  const VerifyButton({super.key, required this.isOtpComplete, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOtpComplete ? AppColors.primaryColor : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('VERIFY', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(width: 10),
          Icon(Icons.check, color: Colors.white),
        ],
      ),
    );
  }
}
