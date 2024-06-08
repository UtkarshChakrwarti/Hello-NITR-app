import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/dialog_helper.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';

class LoginHelper {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late FocusNode usernameFocusNode;
  late FocusNode passwordFocusNode;
  late AnimationController animationController;
  late Animation<double> buttonScaleAnimation;
  ValueNotifier<bool> allFieldsFilled = ValueNotifier(false);
  bool obscureText = true;

  void initializeControllers(
      TickerProvider tickerProvider, BuildContext context) async {
    // Initialize controllers
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    usernameController.addListener(checkFields);
    passwordController.addListener(checkFields);
    obscureText = true;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: tickerProvider,
    );

    buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(usernameFocusNode);
    });
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    animationController.dispose();
  }

  void checkFields() {
    allFieldsFilled.value = usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  void toggleObscureText() {
    obscureText = !obscureText;
  }

  void showErrorDialog(String message, BuildContext context) {
    DialogHelper.showErrorDialog(message, context);
  }

  Future<bool?> showExitConfirmationDialog(BuildContext context) {
    return DialogHelper.showExitConfirmationDialog(context);
  }

  Future<void> launchURL(String url, BuildContext context) async {
    await LinkLauncher.launchURL(url, context);
  }

  void showSimSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        // return SimSelectionScreen();
        return const SizedBox();
      },
    );
  }
}
