import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final double progress;
  final int updatedContacts;
  final int totalContacts;

  const LoadingWidget({
    required this.progress,
    required this.updatedContacts,
    required this.totalContacts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Add the Text updating contacts center aligned and header
        const Text(
          'Updating Contacts...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 40),
        LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.primaryColor,
          size: 50.0,
        ),
        const SizedBox(height: 20),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryColor,
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
      ],
    );
  }
}
