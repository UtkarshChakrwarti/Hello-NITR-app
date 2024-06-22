import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/home/widgets/expanded.dart';

class ContactListItem extends StatelessWidget {
  final User contact;
  final bool isExpanded;
  final Function onTap;
  final Function onDismissed;
  final Function onCall;
  final Function onViewProfile;
  final Widget avatar;

  const ContactListItem({
    Key? key,
    required this.contact,
    required this.isExpanded,
    required this.onTap,
    required this.onDismissed,
    required this.onCall,
    required this.onViewProfile,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fullName = [
      contact.firstName,
      contact.middleName,
      contact.lastName
    ].where((name) => name != null && name.isNotEmpty).join(' ');

    return Dismissible(
      key: ValueKey(contact.empCode),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onCall();
        } else if (direction == DismissDirection.endToStart) {
          onViewProfile();
        }
        return false;
      },
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.33,
        DismissDirection.endToStart: 0.33,
      },
      background: _buildSwipeBackgroundLeft(CupertinoIcons.phone_solid, 'Make Call'),
      secondaryBackground:
          _buildSwipeBackgroundRight(CupertinoIcons.person_crop_circle_fill, 'View Profile'),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
        padding: EdgeInsets.symmetric(
            horizontal: 16.0, vertical: isExpanded ? 12.0 : 6.0),
        decoration: BoxDecoration(
          color: isExpanded ? Color(0xFFFDEEE8) : Colors.white,
          borderRadius: BorderRadius.circular(isExpanded ? 16.0 : 0.0),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: avatar,
              title: Text(
                fullName,
                style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                contact.email ?? '',
                style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onTap(),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded ? ExpandedMenu(contact: contact) : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackgroundLeft(IconData icon, String label) {
    return Container(
      color: AppColors.primaryColor,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8.0),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(width: 20.0), // Ensures spacing for alignment
        ],
      ),
    );
  }

  Widget _buildSwipeBackgroundRight(IconData icon, String label) {
    return Container(
      color: AppColors.primaryColor,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 20.0), // Ensures spacing for alignment
          Row(
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8.0),
              Icon(icon, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
