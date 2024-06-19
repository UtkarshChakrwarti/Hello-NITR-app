import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.primaryColor),
            SizedBox(width: 10),
            Text(
              'Error',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

