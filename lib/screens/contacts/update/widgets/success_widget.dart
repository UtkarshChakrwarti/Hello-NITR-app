import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class SuccessWidget extends StatelessWidget {
  final Animation<double> animation;
  final int updatedContacts;
  final int totalContacts;
  final VoidCallback onPressed;

  const SuccessWidget({
    required this.animation,
    required this.updatedContacts,
    required this.totalContacts,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: animation,
          child: const Icon(
            CupertinoIcons.check_mark_circled,
            color: AppColors.primaryColor,
            size: 100, // Larger icon
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: animation,
          child: const Text(
            'Contacts Updated Successfully!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Updated Contacts: $updatedContacts/$totalContacts',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.all(20),
          ),
          onPressed: onPressed,
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}