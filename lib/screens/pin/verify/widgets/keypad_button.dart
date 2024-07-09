import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class KeypadButton extends StatelessWidget {
  final dynamic value;
  final VoidCallback onPressed;

  const KeypadButton({super.key, required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.2;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          splashColor: AppColors.secondaryColor.withOpacity(0.2),
          highlightColor: AppColors.secondaryColor.withOpacity(0.2),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Center(
              child: value is IconData
                  ? Icon(
                      value,
                      size: 35,
                      color: theme.primaryColor,
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.primaryColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
