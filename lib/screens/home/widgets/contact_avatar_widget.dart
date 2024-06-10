import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'dart:convert';

class ContactAvatarWidget extends StatelessWidget {
  final String base64Image;
  final String firstName;
  final String uniqueKey;
  final Map<String, Uint8List?> imageCache;
  final double textScaleFactor;

  const ContactAvatarWidget({
    required this.base64Image,
    required this.firstName,
    required this.uniqueKey,
    required this.imageCache,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes = _getImageBytes(base64Image, uniqueKey);

    if (imageBytes == null) {
      return _buildInitialAvatar(firstName);
    }

    return Container(
      padding: EdgeInsets.all(1), // Add padding to create space for the border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.primaryColor,
            width: 1), // Set border color and width
      ),
      child: CircleAvatar(
        backgroundImage: MemoryImage(imageBytes),
      ),
    );
  }

  Uint8List? _getImageBytes(String base64Image, String key) {
    if (imageCache.containsKey(key)) {
      return imageCache[key];
    } else if (_isValidBase64(base64Image)) {
      try {
        Uint8List imageBytes = base64Decode(base64Image);
        imageCache[key] = imageBytes;
        return imageBytes;
      } catch (e) {
        imageCache[key] = null;
        return null;
      }
    } else {
      imageCache[key] = null;
      return null;
    }
  }

  bool _isValidBase64(String base64Image) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(base64Image);
  }

  Widget _buildInitialAvatar(String firstName) {
    return Container(
      padding: EdgeInsets.all(1), // Add padding to create space for the border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.primaryColor,
            width: 1), // Set border color and width
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.primaryColor, // Use theme color
        child: Text(
          firstName[0],
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 14 * textScaleFactor,
          ),
        ),
      ),
    );
  }
}
