import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/models/user.dart';

class UserProfileHeader extends StatelessWidget {
  final User user;

  UserProfileHeader(this.user);

  bool _isValidBase64(String base64String) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(base64String);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double avatarRadius = mediaQuery.size.width * 0.12;
    final double headerHeight = mediaQuery.size.height * 0.25;

    final String fullName = [
      user.firstName,
      user.middleName,
      user.lastName
    ].where((name) => name != null && name.isNotEmpty).join(' ');

    return Container(
      height: headerHeight,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: user.photo != null && _isValidBase64(user.photo!)
                  ? Image.memory(
                      base64Decode(user.photo!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.primaryColor,
                    ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: AppColors.primaryColor.withOpacity(0.8),
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage:
                        user.photo != null && _isValidBase64(user.photo!)
                            ? MemoryImage(base64Decode(user.photo!))
                            : null,
                    backgroundColor: Colors.white,
                    child: user.photo == null || !_isValidBase64(user.photo!)
                        ? Text(
                            "${user.firstName![0]}",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: avatarRadius * 0.6,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          )
                        : null,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    fullName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${user.departmentCode}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
