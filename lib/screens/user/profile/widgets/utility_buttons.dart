import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';
import 'package:hello_nitr/controllers/user_profile_controller.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/utils/dialogs_and_prompts.dart';
import 'package:hello_nitr/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'package:hello_nitr/screens/user/profile/widgets/icon_button.dart';
import 'package:logging/logging.dart';

class UtilityButtons extends StatelessWidget {
  final UserProfileController controller;

  UtilityButtons(this.controller);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButtonWidget(
                icon: Icons.sync,
                label: "Sync",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/contactsUpdate');
                },
              ),
              IconButtonWidget(
                icon: Icons.privacy_tip,
                label: "Privacy Policy",
                iconSize: 22.0,
                fontSize: 11.0,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TermsAndConditionsScreen(),
                  ));
                },
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButtonWidget(
                icon: CupertinoIcons.device_phone_portrait,
                label: "Deregister",
                iconSize: 22.0,
                fontSize: 12.0,
                onTap: () {
                  LocalStorageService.getCurrentUser().then((user) {
                    showDeRegisterDeviceDialog(context, user!.empCode!);
                  });
                },
              ),
              IconButtonWidget(
                icon: Icons.logout,
                label: "Log Out",
                iconSize: 22.0,
                fontSize: 12.0,
                onTap: () async {
                  final shouldExit =
                      await DialogsAndPrompts.showLogoutConfirmationDialog(
                          context);
                  if (shouldExit != null && shouldExit) {
                    await controller.logout(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> showDeRegisterDeviceDialog(
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
              'Are you sure you want to Deregister your Device?',
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
              onPressed: () async {
                try {
                  await controller.deRegisterDevice(empCode);
                  LoginController().logout(context);
                } catch (e, stackTrace) {
                  final logger = Logger('UtilityButtons');
                  logger.severe('Error during de-register', e, stackTrace);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
