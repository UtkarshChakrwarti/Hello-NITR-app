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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
      title: Text(title, style: const TextStyle(fontFamily: 'Roboto')),
      subtitle: Text(subtitle!, style: const TextStyle(fontFamily: 'Roboto')),
      trailing: IconButton(
        icon: const Icon(CupertinoIcons.mail_solid, color: AppColors.primaryColor),
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