import 'package:flutter/material.dart';
import 'package:hello_nitr/providers/login_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hello_nitr/controllers/pin_creation_controller.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PinUnlockScreenController {
  final PinCreationController _pinCreationController = PinCreationController();
  final LoginProvider _loginProvider = LoginProvider();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Logger _logger = Logger('PinUnlockScreenController');

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e, stackTrace) {
      _logger.severe("Error checking biometrics: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to Access Hello NITR',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e, stackTrace) {
      _logger.severe("Error during biometric authentication: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> validatePin(String pin) async {
    try {
      return await _pinCreationController.validatePin(pin);
    } catch (e, stackTrace) {
      _logger.severe("Error validating PIN: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  void logout(BuildContext context) {
    try {
      _loginProvider.logout(context);
      _logger.info('User logged out successfully');
    } catch (e, stackTrace) {
      _logger.severe("Logout failed: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
}
