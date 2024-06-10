import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'menu_button_widget.dart';

class ExpandedMenuWidget extends StatelessWidget {
  final User contact;
  final double iconSize;

  const ExpandedMenuWidget({
    required this.contact,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MenuButtonWidget(
            icon: CupertinoIcons.phone_solid,
            onPressed: () => LinkLauncher.makeCall(contact.mobile ?? ""),
          ),
          MenuButtonWidget(
            icon: FontAwesomeIcons.whatsapp,
            onPressed: () => LinkLauncher.sendWpMsg(contact.mobile ?? ""),
          ),
          MenuButtonWidget(
            icon: CupertinoIcons.chat_bubble_text_fill,
            onPressed: () => LinkLauncher.sendMsg(contact.mobile ?? ""),
          ),
          MenuButtonWidget(
            icon: CupertinoIcons.mail_solid,
            onPressed: () => LinkLauncher.sendEmail(contact.email ?? ""),
          ),
          MenuButtonWidget(
            icon: CupertinoIcons.profile_circled,
            onPressed: () {
              // push to contact profile screen with contact details
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ContactProfileScreen(contact),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
