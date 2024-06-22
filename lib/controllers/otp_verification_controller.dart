import 'dart:async';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/core/utils/device_id/device_id.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:logging/logging.dart';
import 'package:otp/otp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OtpVerificationController {
  final LoginProvider _loginProvider = LoginProvider();
  final Logger _logger = Logger('OtpVerificationController');
  final ApiService _apiService = ApiService();
  String generatedOtp = '';
  DateTime otpGenerationTime = DateTime.now();

  /// Generates a time-based OTP TOTP valid for 10 minutes after generation.
  String _generateOtp() {
    final otp = OTP.generateTOTPCodeString(
      AppConstants.securityKey,
      DateTime.now().millisecondsSinceEpoch,
      interval: 60,  // time interval in seconds for OTP generation
      length: 6,
      algorithm: Algorithm.SHA256,
    );
    otpGenerationTime = DateTime.now();
    _logger.info('Generated OTP: $otp');
    return otp;
  }

  // Sends the generated OTP to the specified mobile number.
  Future<void> sendOtp(String mobileNumber) async {
    try {
      generatedOtp = _generateOtp();
      await _apiService.sendOtp(mobileNumber, generatedOtp);
      _logger.info("OTP sent to $mobileNumber");
    } catch (e, stackTrace) {
      _logger.severe("Failed to send OTP: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // OTP verification with expiration check.
  Future<bool> verifyOtp(String enteredOtp) async {
    final currentTime = DateTime.now();
    final otpValidityDuration = Duration(seconds: 600); // OTP valid for 10 minutes (600 seconds)
    if (currentTime.isBefore(otpGenerationTime.add(otpValidityDuration))) {
      if (enteredOtp == generatedOtp) {
        _logger.info('OTP verified successfully');
        return true;
      } else {
        _logger.warning('Invalid OTP entered');
        return false;
      }
    } else {
      _logger.warning('OTP expired');
      return false;
    }
  }

  // Logs out the user and navigates to the login screen.
  Future<void> logout(context) async {
    try {
      await _loginProvider.logout(context);
      _logger.info('User logged out successfully');
    } catch (e, stacktrace) {
      _logger.severe("Logout failed: $e");
      Sentry.captureException(e, stackTrace: stacktrace);
    }
  }

  Future<void> updateDeviceId() async {
    try {
      final String udid = await DeviceUtil().getDeviceID();
      LoginResponse? currentUser = await LocalStorageService.getLoginResponse();
      await _apiService.updateDeviceId(currentUser!.empCode, udid);
      _logger.info('Device ID updated successfully');
    } catch (e, stackTrace) {
      _logger.severe("Device ID update failed: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
}
