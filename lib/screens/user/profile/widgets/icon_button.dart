import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  const IconButtonWidget({super.key, 
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      splashColor: AppColors.secondaryColor.withOpacity(0.3),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: iconSize),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: fontSize,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
