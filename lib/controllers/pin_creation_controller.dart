import 'dart:async';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PinCreationController {
  final Logger _logger = Logger('PinCreationController');

  Future<void> savePin(String pin) async {
    try {
      await LocalStorageService.savePin(pin);
      String? savedPin = await LocalStorageService.getPin();
      _logger.info('Saved PIN: $savedPin');
    } catch (e, stackTrace) {
      _logger.severe('Failed to save PIN: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<bool> validatePin(String pin) async {
    try {
      String? savedPin = await LocalStorageService.getPin();
      _logger.info('Saved PIN: $savedPin');
      return savedPin == pin;
    } catch (e, stackTrace) {
      _logger.severe('Failed to validate PIN: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }
}
