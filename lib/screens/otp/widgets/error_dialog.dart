import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  ErrorDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Row(
        children: [
          Icon(Icons.error, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Text('Error', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
