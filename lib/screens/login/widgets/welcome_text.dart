import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text("Welcome to",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontFamily: 'Roboto')),
            Text("Hello NITR",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontFamily: 'Roboto')),
            Text("v 2.0",
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryColor,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}