import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';

class ContactTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isMobile;

  const ContactTile({
    required this.title,
    required this.subtitle,
    required this.isMobile,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.phone_solid, color: AppColors.primaryColor),
            onPressed: () => _launchCall(context, subtitle!),
          ),
          if (isMobile) ...[
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(FontAwesomeIcons.whatsapp, color: AppColors.primaryColor),
              onPressed: () => _launchWhatsApp(context, subtitle!),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(CupertinoIcons.chat_bubble_text_fill,
                  color: AppColors.primaryColor),
              onPressed: () => _launchMessage(context, subtitle!),
            ),
          ],
        ],
      ),
    );
  }

void _launchCall(BuildContext context, String number) {
    try {
      LinkLauncher.makeCall(number);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to make call: $e')),
      );
    }
  }

  void _launchWhatsApp(BuildContext context, String number) {
    try {
      LinkLauncher.sendWpMsg(number);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open WhatsApp: $e')),
      );
    }
  }

  void _launchMessage(BuildContext context, String number) {
    try {
      LinkLauncher.sendMsg(number);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
}
