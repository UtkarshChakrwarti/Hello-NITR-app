import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/contacts/profile/contact_profile_screen.dart';

class ExpandedMenu extends StatelessWidget {
  final User contact;

  const ExpandedMenu({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFFFDEEE8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Divider(thickness: 1, color: AppColors.primaryColor.withOpacity(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(CupertinoIcons.phone_solid, () {
                LinkLauncher.makeCall(contact.mobile ?? '');
              }),
              _buildIconButton(FontAwesomeIcons.whatsapp, () {
                LinkLauncher.sendWpMsg(contact.mobile ?? '');
              }),
              _buildIconButton(CupertinoIcons.chat_bubble_text_fill , () {
                LinkLauncher.sendMsg(contact.mobile ?? '');
              }),
              _buildIconButton(CupertinoIcons.mail_solid, () {
                LinkLauncher.sendEmail(contact.email ?? '');
              }),
              _buildIconButton(CupertinoIcons.person_crop_circle_fill, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactProfileScreen(contact),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: AppColors.primaryColor, size: 30.0),
      onPressed: onPressed,
    );
  }
}
