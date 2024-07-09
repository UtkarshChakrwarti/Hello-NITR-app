import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/utility_functions.dart';
import 'package:hello_nitr/models/user.dart';

class ProfileHeader extends StatelessWidget {
  final User contact;

  const ProfileHeader({
    required this.contact,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final String fullName = [
      contact.firstName,
      contact.middleName,
      contact.lastName
    ].where((name) => name != null && name.isNotEmpty).join(' ');

    bool isImageValid =
        contact.photo != null && UtilityFunctions().isValidBase64Image(contact.photo!);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage:
                isImageValid ? MemoryImage(base64Decode(contact.photo!)) : null,
            child: !isImageValid
                ? Text(
                    "${contact.firstName![0]}",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  )
                : null,
            backgroundColor: AppColors.secondaryColor,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 5),
              Text(
                contact.designation ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                contact.departmentName ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
