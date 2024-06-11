import 'package:flutter/material.dart';
import 'package:hello_nitr/controllers/login_controller.dart';

class LoginProvider with ChangeNotifier {
  final LoginController _loginController = LoginController();
  bool isLoading = false;
  bool isAuthenticated = false;
  bool isFreshLoginAttempt = false;
  bool isAllowedToLogin = false;
  bool invalidUserNameOrPassword = false;

  Future<bool> login(
      String userId, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    bool result = await _loginController.login(userId, password, context);

    isLoading = false;
    isAuthenticated = result;
    notifyListeners();

    return result;
  }

  Future<void> logout(BuildContext context) async {
    await _loginController.logout(context);
    isAuthenticated = false;
    notifyListeners();
  }

    // Method to set isFreshLoginAttempt
  void setFreshLoginAttempt(bool value) {
    isFreshLoginAttempt = value;
    notifyListeners();
  }

  // Method to set isAllowedToLogin
  void setAllowedToLogin(bool value) {
    isAllowedToLogin = value;
    notifyListeners();
  }

  // Method to set invalidUserNameOrPassword
  void setInvalidUserNameOrPassword(bool value) {
    invalidUserNameOrPassword = value;
    notifyListeners();
  }
}
