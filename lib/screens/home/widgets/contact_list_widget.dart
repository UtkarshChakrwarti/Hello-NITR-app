import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/models/user.dart';
import 'contact_item_widget.dart';

class ContactListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final List<User> contacts;
  final bool isSearchActive;
  final bool isLoadingMoreContacts;
  final Function(int) onContactTap;
  final int? selectedContactIndex;
  final bool isMenuVisible;
  final Duration animationDuration;
  final Uint8List? Function(String base64Image, String key) getImageBytes;
  final Color revealBackgroundColor;
  final Color selectedBackgroundColor;
  final double textScaleFactor;
  final double iconSize;
  final Map<String, Uint8List?> imageCache;

  const ContactListWidget({
    required this.scrollController,
    required this.contacts,
    required this.isSearchActive,
    required this.isLoadingMoreContacts,
    required this.onContactTap,
    required this.selectedContactIndex,
    required this.isMenuVisible,
    required this.animationDuration,
    required this.getImageBytes,
    required this.revealBackgroundColor,
    required this.selectedBackgroundColor,
    required this.textScaleFactor,
    required this.iconSize,
    required this.imageCache,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: ClampingScrollPhysics(),
      itemCount: isSearchActive
          ? contacts.length
          : contacts.length + (isLoadingMoreContacts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == (isSearchActive ? contacts.length : contacts.length)) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ));
        }
        var contact = contacts[index];
        String fullName = contact.firstName! +
            (contact.middleName == "" ? "" : " ${contact.middleName}") +
            (contact.lastName!.isEmpty ? "" : " ${contact.lastName}");

        bool isExpanded = selectedContactIndex == index && isMenuVisible;
        return ContactItemWidget(
          contact: contact,
          fullName: fullName,
          isExpanded: isExpanded,
          animationDuration: animationDuration,
          getImageBytes: getImageBytes,
          revealBackgroundColor: revealBackgroundColor,
          selectedBackgroundColor: selectedBackgroundColor,
          textScaleFactor: textScaleFactor,
          iconSize: iconSize,
          onContactTap: () => onContactTap(index),
          imageCache: imageCache,
        );
      },
    );
  }
}
