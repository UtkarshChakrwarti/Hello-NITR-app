import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';

class LoginProvider with ChangeNotifier {
  final LoginController _loginController = LoginController();
  bool isLoading = false;
  bool isAuthenticated = false;
  bool isDeviceVerified = false;

  Future<int> login(
      String userId, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    int result = await _loginController.login(userId, password);

    if (result == 1) {
      isAuthenticated = true;
    } else if (result == 2 || result == 3 || result == 5) {
      isDeviceVerified = false;
    }

    isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout(BuildContext context) async {
    await _loginController.logout(context);
    isAuthenticated = false;
    isDeviceVerified = false;
    notifyListeners();
  }
}
