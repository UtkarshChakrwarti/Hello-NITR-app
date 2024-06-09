import 'package:flutter/material.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/device_id/device_id.dart';
import 'package:hello_nitr/core/utils/encryption_functions.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:logging/logging.dart';

class LoginController {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger('LoginController');

  Future<int> login(String userId, String password) async {
    _logger.info('Attempting login for user: $userId');

    try {
      String encryptedPassword = EncryptionFunction().encryptPassword(password);
      LoginResponse response =
          await _apiService.login(userId, encryptedPassword);
      final String udid = await DeviceUtil().getDeviceID();

      if (response.loginSuccess) {
        _logger.info('Login successful for user: $userId');

        // Fresh Login Attempt
        if (response.loggedIn == false || response.loggedIn == null) {
          _logger.info('Fresh Login Attempt');
          bool? isSuccess =
              await _apiService.updateDeviceId(response.empCode, udid);
          if (isSuccess == false) {
            _logger.info('Failed to update device ID');
            return 2; // Device ID update failed
          }
        }
        // Already Logged in on Another Device
        else {
          _logger.info(
              'User already logged in on another device: Check if device is same as the one in the response');
          if (response.deviceIMEI != udid) {
            _logger.info(
                'Device ID does not match. Please contact support for assistance.');
            return 3; // Device ID mismatch
          }
        }

        try {
          await LocalStorageService.saveLoginResponse(response);
          _logger.info('Login response saved and user authenticated');
          return 1; // Login successful
        } catch (e) {
          _logger.info('Failed to save login response: $e');
          return 4; // Failed to save login response
        }
      } else {
        _logger.info('Login failed: Invalid credentials');
        return 6; // Login failed
      }
    } catch (e) {
      _logger.severe('Login failed: $e');
      return 0; // Exception occurred
    }
  }

  Future<void> logout(BuildContext context) async {
    _logger.info('Attempting to logout user');
    try {
      await LocalStorageService.logout();
      Navigator.of(context).maybePop();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      _logger.info('User logged out successfully');
    } catch (e) {
      _logger.severe("Logout failed: $e");
    }
  }
}
