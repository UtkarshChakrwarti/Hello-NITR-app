import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/encryption_functions.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  final ApiService _apiService =  ApiService();
  bool isLoading = false;
  bool isAuthenticated = false;

  Future<bool> login(String userId, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      // Encrypt the password before sending it to the API
      String encryptedPassword = EncryptionFunction().encryptPassword(password);
      LoginResponse response =
          await _apiService.login(userId, encryptedPassword);

      if (response.loginSuccess) {
        // Save the login response securely
        await LocalStorageService.saveLoginResponse(response);

        // Print the user details to the console fetched from the saved session
        LoginResponse? currentUser =
            await LocalStorageService.getLoginResponse();
        print(
            'User logged in (Fetched From saved logged In info from secured storage): ${currentUser!.firstName} ${currentUser.lastName}');

        isAuthenticated = true;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Login failed: ${response.message}');
        isLoading = false;
        isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Login failed: $e");
      isLoading = false;
      isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  //logout function and push to login screen
    Future<void> logout(context) async {
    try {
      await LocalStorageService.logout();
      print('User logged out');
      Navigator.of(context).maybePop();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);

    } catch (e) {
      print("Logout failed: $e");
    }
    }
}
