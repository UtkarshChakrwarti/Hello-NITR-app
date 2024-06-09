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
