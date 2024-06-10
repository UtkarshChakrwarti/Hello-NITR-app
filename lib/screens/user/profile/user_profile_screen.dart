import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/dialogs_and_prompts.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'dart:ui';

class UserProfileScreen extends StatefulWidget {
  final ApiService apiService = ApiService();
  final VoidCallback onSearchCriteriaSelected;
  final Function(String) onFilterByEmployeeType;

  UserProfileScreen({
    required this.onSearchCriteriaSelected,
    required this.onFilterByEmployeeType,
  });

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
      int allEmployeesCount = await LocalStorageService.getTotalUsers();
      int facultiesCount =
          await LocalStorageService.getTotalUsersByEmployeeType('Faculty');
      int officersCount =
          await LocalStorageService.getTotalUsersByEmployeeType('Officer');
      int departmentsCount = await LocalStorageService.getTotalDepartments();

      setState(() {
        contactCounts["All Employees"] = allEmployeesCount;
        contactCounts["Faculties"] = facultiesCount;
        contactCounts["Officers"] = officersCount;
        contactCounts["Departments"] = departmentsCount;
      });
    } catch (e) {
      print('Error fetching contact counts: $e');
    }
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, double iconSize,
      double fontSize, VoidCallback onTap, int count) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      splashColor: AppColors.secondaryColor.withOpacity(0.3),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: iconSize),
            SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: fontSize,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: LocalStorageService.getCurrentUser(),
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
                _buildUserProfileHeader(user, context),
                _buildSectionTitle("Personal Details", 16.0),
                _buildCompactPersonalDetails(user),
                _buildSectionTitle("Filter by", 16.0),
                _buildFilterButtons(),
                Divider(color: Colors.grey[300]),
                _buildUtilityButtons(context),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildUserProfileHeader(User user, BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double avatarRadius = mediaQuery.size.width * 0.12;
    final double headerHeight =
        mediaQuery.size.height * 0.25; // Reduced height for a smaller header

    String fullName = user.firstName! +
        (user.middleName != null && user.middleName!.isNotEmpty
            ? " ${user.middleName}"
            : "") +
        (user.lastName != null && user.lastName!.isNotEmpty
            ? " ${user.lastName}"
            : "");

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
              bottom: 16.0, // Positioned close to the bottom
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

  bool _isValidBase64(String base64String) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(base64String);
  }

  Widget _buildCompactPersonalDetails(User user) {
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
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 16),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
              _buildIconButton(
                  FontAwesomeIcons.users, "All Employees", 22.0, 11.0, () {
                widget.onFilterByEmployeeType('');
              }, contactCounts["All Employees"]!),
              _buildIconButton(Icons.school, "Faculties", 22.0, 11.0, () {
                widget.onFilterByEmployeeType('Faculty');
              }, contactCounts["Faculties"]!),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(
                  FontAwesomeIcons.briefcase, "Officers", 22.0, 11.0, () {
                widget.onFilterByEmployeeType('Officer');
              }, contactCounts["Officers"]!),
              _buildIconButton(
                  Icons.group,
                  "Departments",
                  22.0,
                  11.0,
                  widget.onSearchCriteriaSelected,
                  contactCounts["Departments"]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(Icons.sync, "Sync", 22.0, 11.0, () {
                Navigator.pushReplacementNamed(context, '/contactsUpdate');
              }, 0),
              _buildIconButton(Icons.privacy_tip, "Privacy Policy", 22.0, 11.0,
                  () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TermsAndConditionsScreen(),
                ));
              }, 0),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(CupertinoIcons.device_phone_portrait,
                  "De-Register", 22.0, 12.0, () {
                LocalStorageService.getCurrentUser().then((user) {
                  showDeRegisterDeviceDialog(context, user!.empCode!);
                });
              }, 0),
              _buildIconButton(Icons.logout, "Log Out", 22.0, 12.0, () async {
                try {
                  DialogsAndPrompts.showExitConfirmationDialog(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }, 0),
            ],
          ),
        ],
      ),
    );
  }

  static Future<bool?> showDeRegisterDeviceDialog(
      BuildContext context, String empCode) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Row(
            children: [
              Icon(Icons.delete_forever_rounded, color: AppColors.primaryColor),
              SizedBox(width: 10),
              Text('De-Register',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
              'Are you sure you want to De-Register your Device?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: const Text('No',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                ApiService().deRegisterDevice(empCode);
                // logout the user after de-registering the device
                LoginController().logout(context);
              },
            ),
          ],
        );
      },
    );
  }
}
