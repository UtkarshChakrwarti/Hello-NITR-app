import 'dart:async';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/device_id/device_id.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:logging/logging.dart';

class OtpVerificationController {
  final LoginProvider _loginProvider = LoginProvider();
  final Logger _logger = Logger('OtpVerificationController');
  final ApiService _apiService = ApiService();
 

  /// Simulates fetching OTP from the server.
  Future<String> fetchOtp() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    _logger.info("OTP sent to the user");
    return "000000"; // Mocked OTP
  }

  /// Simulates OTP verification.
  Future<bool> verifyOtp(String enteredOtp, String actualOtp) async {
    return enteredOtp == actualOtp;
  }

  /// Logs out the user and navigates to the login screen.
  Future<void> logout(context) async {
    try {
      await _loginProvider.logout(context);
      _logger.info('User logged out successfully');
    } catch (e) {
      _logger.severe("Logout failed: $e");
    }
  }

  Future<void> updateDeviceId() async {
    try {
       final String udid = await DeviceUtil().getDeviceID();
       LoginResponse? currentUser = await LocalStorageService.getLoginResponse();
      await _apiService.updateDeviceId(currentUser!.empCode, udid);
      _logger.info('Device ID updated successfully');
    } catch (e) {
      _logger.severe("Device ID update failed: $e");
    }
  }
}
