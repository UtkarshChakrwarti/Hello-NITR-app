import 'package:flutter/cupertino.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class UserProfileController {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger('UserProfileController');

  Future<User?> getCurrentUser() async {
    try {
      _logger.info('Fetching current user');
      return await LocalStorageService.getCurrentUser();
    } catch (e, stackTrace) {
      _logger.severe('Error fetching current user', e, stackTrace);
      Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> deRegisterDevice(String empCode) async {
    try {
      _logger.info('Deregistering device for empCode: $empCode');
      await _apiService.deRegisterDevice(empCode);
    } catch (e, stackTrace) {
      _logger.severe('Error deregistering device', e, stackTrace);
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await LocalStorageService.logout();
      _logger.info('User logged out');
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } catch (e, stacktrace) {
      _logger.severe("Logout failed", e, stacktrace);
      Sentry.captureException(e, stackTrace: stacktrace);
    }
  }
}
