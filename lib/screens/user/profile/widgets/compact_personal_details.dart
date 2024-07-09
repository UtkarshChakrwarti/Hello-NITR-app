import 'package:flutter/cupertino.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/models/user.dart';

class CompactPersonalDetails extends StatelessWidget {
  final User user;

  const CompactPersonalDetails(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          _buildCompactListTile(CupertinoIcons.phone_solid, user.mobile),
          _buildCompactListTile(
              CupertinoIcons.building_2_fill, '0661246${user.workPhone}'),
          _buildCompactListTile(CupertinoIcons.mail_solid, user.email),
        ],
      ),
    );
  }

  Widget _buildCompactListTile(IconData icon, String? title) {
    if (title == null || title.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 16),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
