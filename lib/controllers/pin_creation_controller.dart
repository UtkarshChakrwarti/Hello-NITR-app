import 'dart:async';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:logging/logging.dart';

class PinCreationController {
  final Logger _logger = Logger('PinCreationController');

  Future<void> savePin(String pin) async {
    try {
      await LocalStorageService.savePin(pin);
      String? savedPin = await LocalStorageService.getPin();
      _logger.info('Saved PIN: $savedPin');
    } catch (e) {
      _logger.severe('Failed to save PIN: $e');
    }
  }

  Future<bool> validatePin(String pin) async {
    try {
      String? savedPin = await LocalStorageService.getPin();
      _logger.info('Saved PIN: $savedPin');
      return savedPin == pin;
    } catch (e) {
      _logger.severe('Failed to validate PIN: $e');
      return false;
    }
  }
}
