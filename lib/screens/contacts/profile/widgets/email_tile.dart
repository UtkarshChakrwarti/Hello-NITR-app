import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';

class EmailTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  const EmailTile({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.isEmpty) {
      return SizedBox.shrink();
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 1.0),
      title: Text(title, style: TextStyle(fontFamily: 'Roboto')),
      subtitle: Text(subtitle!, style: TextStyle(fontFamily: 'Roboto')),
      trailing: IconButton(
        icon: Icon(CupertinoIcons.mail_solid, color: AppColors.primaryColor),
        onPressed: () => _launchEmail(context, subtitle!),
      ),
    );
  }

  void _launchEmail(BuildContext context, String email) {
    try {
      LinkLauncher.sendEmail(email);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    }
  }
}