import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class StatusMessage extends StatelessWidget {
  final String statusMessage;

  const StatusMessage({super.key, required this.statusMessage});

  @override
  Widget build(BuildContext context) {
    return Text(
      statusMessage,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
}
