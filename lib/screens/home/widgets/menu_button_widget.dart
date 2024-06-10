import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class MenuButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const MenuButtonWidget({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30.0),
          color: AppColors.primaryColor,
          onPressed: onPressed,
          padding: EdgeInsets.all(10.0),
        ),
      ],
    );
  }
}
