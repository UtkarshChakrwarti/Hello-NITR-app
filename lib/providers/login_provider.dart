import 'package:flutter/material.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/device_id/device_id.dart';
import 'package:hello_nitr/core/utils/encryption_functions.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:logging/logging.dart';

class LoginProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  bool isAuthenticated = false;
  final Logger _logger = Logger('LoginProvider');

  /// Logs in the user with the provided [userId] and [password].
  /// Returns:
  /// - 1 on successful login,
  /// - 2 on failure,
  /// - 3 if the user is already logged in on another device.
  Future<int?> login(String userId, String password) async {
    _setLoading(true);
    _logger.info('Attempting login for user: $userId');

    try {
      // Encrypt the password before sending it to the API
      String encryptedPassword = EncryptionFunction().encryptPassword(password);
      LoginResponse response = await _apiService.login(userId, encryptedPassword);

      if (response.loginSuccess) {
        _logger.info('Login successful for user: $userId');

        // Get Device ID
        String udid = await DeviceUtil().getDeviceID();
        _logger.info('Device ID obtained: $udid');

        // Check if device ID matches with login response device ID
        if (response.deviceIMEI != null && response.deviceIMEI!.isNotEmpty && response.deviceIMEI != udid) {
          _handleAuthFailure('Device ID does not match. Please contact support for assistance.');
          return 3;
        }

        // Check if deviceID is null or empty and update it if necessary otherwise save login response
        if (response.deviceIMEI == null || response.deviceIMEI!.isEmpty) {
          bool? isSuccess = await _apiService.updateDeviceId(response.empCode, udid);
          if (isSuccess == false) {
            _handleAuthFailure('Failed to update device ID');
            return 2;
          } 
        }

        try {
          await LocalStorageService.saveLoginResponse(response);
          isAuthenticated = true;
          _setLoading(false);
          _logger.info('Login response saved and user authenticated');
          return 1;
        } catch (e) {
          _handleAuthFailure('Failed to save login response: $e');
          return 2;
        }
      } else {
        _handleAuthFailure('Login failed: ${response.message}');
        return 2;
      }
    } catch (e) {
      _handleAuthFailure('Login failed: $e');
      return 2;
    } finally {
      _setLoading(false);
    }
  }

  /// Logs out the user and navigates to the login screen.
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

  /// Sets the loading state and notifies listeners.
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Handles authentication failure by logging the [message] and updating the state.
  void _handleAuthFailure(String message) {
    _logger.severe(message);
    isAuthenticated = false;
  }
}
