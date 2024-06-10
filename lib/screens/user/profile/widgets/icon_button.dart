import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;
  final int count;

  IconButtonWidget({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      splashColor: AppColors.secondaryColor.withOpacity(0.3),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: iconSize),
            SizedBox(height: 4.0),
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
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}