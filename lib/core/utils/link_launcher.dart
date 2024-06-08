import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkLauncher {
  static Future<void> launchURL(String url, BuildContext context) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url: $e',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }
}
