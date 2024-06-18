import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/user_profile_controller.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/user/profile/widgets/compact_personal_details.dart';
import 'package:hello_nitr/screens/user/profile/widgets/icon_button.dart';
import 'package:hello_nitr/screens/user/profile/widgets/section_title.dart';
import 'package:hello_nitr/screens/user/profile/widgets/user_profile_header.dart';
import 'package:hello_nitr/screens/user/profile/widgets/utility_buttons.dart';
import 'package:hello_nitr/screens/home/department_search_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterSelected;

  const UserProfileScreen({
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final UserProfileController _controller = UserProfileController();

    return FutureBuilder<User?>(
      future: _controller.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading user data'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No user data available'));
        } else {
          User user = snapshot.data!;
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserProfileHeader(user),
                SectionTitle("Personal Details", 16.0),
                CompactPersonalDetails(user),
                SectionTitle("Filter by", 16.0),
                _buildFilterButtons(context),
                Divider(color: Colors.grey[300]),
                UtilityButtons(_controller),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButtonWidget(
                icon: Icons.people,
                label: "All Employees",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  onFilterSelected('All Employee');
                },
              ),
              IconButtonWidget(
                icon: Icons.school,
                label: "Faculties",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  onFilterSelected('Faculty');
                },
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButtonWidget(
                icon: Icons.work,
                label: "Officers",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  onFilterSelected('Officer');
                },
              ),
              IconButtonWidget(
                icon: Icons.group,
                label: "Departments",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  // Close the drawer
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DepartmentSearchScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


