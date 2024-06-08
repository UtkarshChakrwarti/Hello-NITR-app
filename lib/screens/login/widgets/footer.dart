import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:hello_nitr/screens/login/login_helper.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginHelper = LoginHelper();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("\u{00A9} NIT Rourkela 2024 \nDesigned and Developed by ",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontFamily: 'Roboto')),
        GestureDetector(
          onTap: () => loginHelper.launchURL(AppConstants.catUrl, context),
          child: const Text("Centre for Automation Technology",
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
