import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String header;
  final String waitMessage;
  final double progress;
  final int updatedContacts;
  final int totalContacts;
  final bool showCounter;

  const LoadingWidget({
    required this.header,
    required this.waitMessage,
    required this.progress,
    required this.updatedContacts,
    required this.totalContacts,
    required this.showCounter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Updating Contacts',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          header,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.primaryColor,
          size: 100.0,
        ),
        const SizedBox(height: 40),
        if (showCounter) ...[
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
          const SizedBox(height: 20),
        ],
        Text(
          waitMessage,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
