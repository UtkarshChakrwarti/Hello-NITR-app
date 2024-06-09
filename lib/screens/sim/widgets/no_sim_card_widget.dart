import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class NoSimCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor),
      ),
      padding: EdgeInsets.all(16),
      child: const Column(
        children: [
          Icon(Icons.sim_card_alert, color: AppColors.primaryColor, size: 50),
          SizedBox(height: 10),
          Text(
            "SIM card not found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
