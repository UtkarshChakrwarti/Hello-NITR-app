import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/services/api/remote/api_service.dart';
import 'package:hello_nitr/models/login.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
//import 'package:hello_nitr/providers/login_provider.dart';
import 'package:logging/logging.dart';

class SplashScreenController {
  final Logger _logger = Logger('SplashScreen');
  //final LoginProvider _loginProvider = LoginProvider();

  Future<String?> checkLoginStatus(BuildContext context) async {
    try {
      bool isLoggedIn = await LocalStorageService.checkIfUserIsLoggedIn();
      String? storedPin = await LocalStorageService.getPin();

      _logger.info('Login status: $isLoggedIn');
      _logger.info('Stored PIN: $storedPin');

      LoginResponse? loginResponse =
          await LocalStorageService.getLoginResponse();
      _logger.info('User Name: ${loginResponse?.firstName}');

      //check if the logged in status duration has expired
      // For Future use if needed
      // if (await logoutOnExpiry()) {
      //   await LocalStorageService.logout();
      //   _logger.info(
      //       'User logged out because the logged in status duration has expired.');
      //   _loginProvider.setExpiredSession(true);
      //   _logger.info('Redirecting to login screen.');
      //   _logger.info('Session expired ${_loginProvider.expiredSession}');
      //   return '/login';
      // }

      //check if the user is logged in and the user is valid
      if (isLoggedIn) {
        try {
          bool isValid =
              await ApiService().validateUser(loginResponse?.empCode);
          _logger.info('User is valid: $isValid');
          if (!isValid) {
            await LocalStorageService.logout();
            _logger
                .info('User logged out because the user is not valid anymore.');
            return '/login';
          }
        } catch (e) {
          _logger.severe('Unable to check User Status : Connectivity issues');
        }
        if (storedPin != null) {
          _logger
              .info('User is still valid, Redirecting to PIN unlock screen.');
          return '/pinUnlock';
        } else {
          await LocalStorageService.logout();
          _logger.info(
              'User is still valid or currently app offline but User\'s Pin is not set, Redirecting to login screen.');
          return '/login';
        }
      } else {
        _logger.info('User is not logged in. Redirecting to login screen.');
        return '/login';
      }
    } on PlatformException catch (e) {
      _logger.severe('PlatformException occurred: $e');
      return null;
    } catch (e) {
      _logger.severe('An error occurred: $e');
      return null;
    }
  }

  Future<bool> logoutOnExpiry() async {
    try {
      bool isLoggedIn = await LocalStorageService.checkIfUserIsLoggedIn();
      if (isLoggedIn) {
        DateTime? loginTime = await LocalStorageService.getLoginTime();
        _logger.info('Login Time: $loginTime');
        if (loginTime != null) {
          DateTime expiryTime = loginTime.add(const Duration(days: 30));
          if (DateTime.now().isAfter(expiryTime)) {
            return true;
          }
        }
      }
    } catch (e) {
      _logger.severe('An error occurred: $e');
    }

    return false;
  }
}
