import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/user_profile_controller.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/user/profile/widgets/compact_personal_details.dart';
import 'package:hello_nitr/screens/user/profile/widgets/filter_buttons.dart';
import 'package:hello_nitr/screens/user/profile/widgets/section_title.dart';
import 'package:hello_nitr/screens/user/profile/widgets/user_profile_header.dart';
import 'package:hello_nitr/screens/user/profile/widgets/utility_buttons.dart';

class UserProfileScreen extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterSelected;

  const UserProfileScreen({super.key, 
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<User?>(
        future: UserProfileController().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          } else {
            return UserProfileContent(
              user: snapshot.data!,
              currentFilter: currentFilter,
              onFilterSelected: onFilterSelected,
            );
          }
        },
      ),
    );
  }
}

class UserProfileContent extends StatelessWidget {
  final User user;
  final String currentFilter;
  final Function(String) onFilterSelected;

  const UserProfileContent({super.key, 
    required this.user,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserProfileHeader(user),
        const SectionTitle("Personal Details", 16.0),
        CompactPersonalDetails(user),
        const SectionTitle("Filter by", 16.0),
        FilterButtons(
          onFilterSelected: onFilterSelected,
        ),
        Divider(color: Colors.grey[300]),
        UtilityButtons(UserProfileController()),
      ],
    );
  }
}
