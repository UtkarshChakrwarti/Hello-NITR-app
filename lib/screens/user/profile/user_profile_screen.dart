import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/user_profile_controller.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/user/profile/widgets/compact_personal_details.dart';
import 'package:hello_nitr/screens/user/profile/widgets/icon_button.dart';
import 'package:hello_nitr/screens/user/profile/widgets/section_title.dart';
import 'package:hello_nitr/screens/user/profile/widgets/user_profile_header.dart';
import 'package:hello_nitr/screens/user/profile/widgets/utility_buttons.dart';
import 'package:logging/logging.dart';

class UserProfileScreen extends StatefulWidget {
  final VoidCallback onSearchCriteriaSelected;
  final Function(String) onFilterByEmployeeType;
  final Future<void> Function() onLogout;

  UserProfileScreen({
    required this.onSearchCriteriaSelected,
    required this.onFilterByEmployeeType,
    required this.onLogout,
  });

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileController _controller = UserProfileController();
  final Logger _logger = Logger('UserProfileScreen');

  Map<String, int> contactCounts = {
    "All Employees": 0,
    "Faculties": 0,
    "Officers": 0,
    "Departments": 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchContactCounts();
  }

  Future<void> _fetchContactCounts() async {
    try {
      _logger.info('Fetching contact counts');
      Map<String, int> counts = await _controller.fetchContactCounts();
      setState(() {
        contactCounts = counts;
      });
    } catch (e, stackTrace) {
      _logger.severe('Error fetching contact counts', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildFilterButtons(),
                Divider(color: Colors.grey[300]),
                UtilityButtons(_controller),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildFilterButtons() {
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
                    widget.onFilterByEmployeeType('');
                  },
                  count: contactCounts["All Employees"]!),
              IconButtonWidget(
                  icon: Icons.school,
                  label: "Faculties",
                  iconSize: 22.0,
                  fontSize: 11.0,
                  onTap: () {
                    widget.onFilterByEmployeeType('Faculty');
                  },
                  count: contactCounts["Faculties"]!),
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
                    widget.onFilterByEmployeeType('Officer');
                  },
                  count: contactCounts["Officers"]!),
              IconButtonWidget(
                  icon: Icons.group,
                  label: "Departments",
                  iconSize: 22.0,
                  fontSize: 11.0,
                  onTap: widget.onSearchCriteriaSelected,
                  count: contactCounts["Departments"]!),
            ],
          ),
        ],
      ),
    );
  }
}
