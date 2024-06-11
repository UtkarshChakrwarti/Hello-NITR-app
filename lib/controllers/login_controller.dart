import 'package:flutter/material.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/device_id/device_id.dart';
import 'package:hello_nitr/core/utils/encryption_functions.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LoginController {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger('LoginController');

  Future<bool> login(
      String userId, String password, BuildContext context) async {
    try {
      // Encrypt the password before sending it to the API
      String encryptedPassword = EncryptionFunction().encryptPassword(password);
      LoginResponse response =
          await _apiService.login(userId, encryptedPassword);
              final loginProvider =
            Provider.of<LoginProvider>(context, listen: false);
      if (response.loginSuccess) {
        // Save the login response securely
        await LocalStorageService.saveLoginResponse(response);

        // Fetch the user details from the saved session
        LoginResponse? currentUser =
            await LocalStorageService.getLoginResponse();
        _logger.info(
            'User logged in (Fetched From saved logged In info from secured storage): ${currentUser!.firstName} ${currentUser.lastName}');



        if (response.loggedIn == true) {
          // User Already Logged In somewhere else so check if this is the same device or not
          final String udid = await DeviceUtil().getDeviceID();
          if (udid != response.deviceIMEI) {
            // Different device
            loginProvider.setAllowedToLogin(false);
            loginProvider.setInvalidUserNameOrPassword(false);
            _logger.warning(
                'User logged in from a different device thus not allowed to login from this device.');
            _logger.warning(
                'Device IMEI: $udid, Device IMEI from API: ${response.deviceIMEI}');
            _logger.info(
                'Is Allowed to login : ${loginProvider.isAllowedToLogin}');
            return false;
          }
        }

        loginProvider.setFreshLoginAttempt(false);
        loginProvider.setAllowedToLogin(true);
        _logger.info(
            'Is Fresh Login Attempt : ${loginProvider.isFreshLoginAttempt}');
        _logger.info('Is Allowed to login : ${loginProvider.isAllowedToLogin}');
        _logger.info('User logged in');

        // Navigate to the next screen
        //Navigator.of(context).pushNamed('/nextScreen');
        return true;
      } else {
        loginProvider.setInvalidUserNameOrPassword(true);
        _logger.warning('Login failed: ${response.message}');
        return false;
      }
    } catch (e, stacktrace) {
      _logger.severe("Login failed", e, stacktrace);
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await LocalStorageService.logout();
      _logger.info('User logged out');
      Navigator.of(context).maybePop();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } catch (e, stacktrace) {
      _logger.severe("Logout failed", e, stacktrace);
    }
  }
}
