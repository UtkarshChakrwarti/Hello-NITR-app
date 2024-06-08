import 'package:flutter/material.dart';
import 'package:hello_nitr/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("By signing in, you agree to our ",
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontFamily: 'Roboto'),
            textAlign: TextAlign.center),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen())),
          child: const Text("Terms and Conditions",
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
