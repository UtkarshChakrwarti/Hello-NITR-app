import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/contacts/profile/contact_profile_screen.dart';
import 'contact_avatar_widget.dart';
import 'expanded_menu_widget.dart';

class ContactItemWidget extends StatelessWidget {
  final User contact;
  final String fullName;
  final bool isExpanded;
  final Duration animationDuration;
  final Uint8List? Function(String base64Image, String key) getImageBytes;
  final Color revealBackgroundColor;
  final Color selectedBackgroundColor;
  final double textScaleFactor;
  final double iconSize;
  final VoidCallback onContactTap;
  final Map<String, Uint8List?> imageCache;

  const ContactItemWidget({
    required this.contact,
    required this.fullName,
    required this.isExpanded,
    required this.animationDuration,
    required this.getImageBytes,
    required this.revealBackgroundColor,
    required this.selectedBackgroundColor,
    required this.textScaleFactor,
    required this.iconSize,
    required this.onContactTap,
    required this.imageCache,
  });

  @override
  Widget build(BuildContext context) {
    return isExpanded
        ? _buildContactItem(context)
        : GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                LinkLauncher.makeCall(contact.mobile ?? '');
              }
            },
            child: Dismissible(
              key: Key(contact.mobile ?? ''),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  LinkLauncher.makeCall(contact.mobile ?? '');
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  //Navigate to the contact profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactProfileScreen(contact),
                    ),
                  );
                  return false;
                }
                return false;
              },
              background: Container(
                color: AppColors.lightSecondaryColor,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.phone_solid,
                      color: AppColors.primaryColor,
                      size: iconSize,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Make Call",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        fontSize: 14 * textScaleFactor,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                color: AppColors.lightSecondaryColor,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "View Profile",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        fontSize: 14 * textScaleFactor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      CupertinoIcons.profile_circled,
                      color: AppColors.primaryColor,
                      size: iconSize,
                    ),
                  ],
                ),
              ),
              child: _buildContactItem(context),
            ),
          );
  }

  Widget _buildContactItem(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      padding: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: isExpanded ? 12.0 : 6.0),
      decoration: BoxDecoration(
        color: isExpanded ? selectedBackgroundColor : Colors.white,
        borderRadius: BorderRadius.circular(isExpanded ? 16.0 : 0.0),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
            leading: contact.photo != null
                ? ContactAvatarWidget(
                    base64Image: contact.photo!,
                    firstName: contact.firstName!,
                    uniqueKey: contact.mobile ?? '',
                    imageCache: imageCache,
                    textScaleFactor: textScaleFactor,
                  )
                : CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      contact.firstName![0],
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    ),
                  ),
            title: Text(
              fullName,
              style: TextStyle(
                  fontSize: 16 * textScaleFactor, fontFamily: 'Roboto'),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              contact.email!,
              style: TextStyle(
                  fontSize: 14 * textScaleFactor, fontFamily: 'Roboto'),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: onContactTap,
          ),
          if (isExpanded)
            Divider(
                thickness: 1, color: AppColors.primaryColor.withOpacity(0.5)),
          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild:
                ExpandedMenuWidget(contact: contact, iconSize: iconSize),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: animationDuration,
          ),
        ],
      ),
    );
  }
}
