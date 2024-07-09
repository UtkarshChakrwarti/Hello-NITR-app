import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/utility_functions.dart';

class Avatar extends StatelessWidget {
  final String? photoUrl;
  final String? firstName;
  final UtilityFunctions utilityFunctions;

  const Avatar({
    Key? key,
    required this.photoUrl,
    required this.firstName,
    required this.utilityFunctions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      if (UtilityFunctions().isValidBase64Image(photoUrl!)) {
        return _buildCircleAvatar(
          backgroundImage: MemoryImage(base64Decode(photoUrl!)),
        );
      } else if (Uri.tryParse(photoUrl!)?.hasAbsolutePath ?? false) {
        return _buildCircleAvatar(
          backgroundImage: CachedNetworkImageProvider(photoUrl!),
        );
      }
    }
    return _buildCircleAvatar(
      child: Text(
        firstName?.isNotEmpty == true ? firstName![0] : '',
        style: TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto'),
      ),
    );
  }

  Widget _buildCircleAvatar({ImageProvider? backgroundImage, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.secondaryColor,
        backgroundImage: backgroundImage,
        child: child,
      ),
    );
  }
}
