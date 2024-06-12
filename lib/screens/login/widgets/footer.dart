import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("\u{00A9} NIT Rourkela 2024 \nDesigned and Developed by ",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontFamily: 'Roboto')),
        GestureDetector(
          onTap: () => LinkLauncher.launchURL(AppConstants.catUrl),
          child: Text("Centre for Automation Technology",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  decoration: TextDecoration.underline)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
