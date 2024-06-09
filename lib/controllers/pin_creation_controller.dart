import 'dart:async';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:logging/logging.dart';

class PinCreationController {
  final Logger _logger = Logger('PinCreationController');

  Future<void> savePin(String pin) async {
    await LocalStorageService.savePin(pin);
    String? savedPin = await LocalStorageService.getPin();
    _logger.info('Saved PIN: $savedPin');
  }

  Future<bool> validatePin(String pin) async {
    String? savedPin = await LocalStorageService.getPin();
    _logger.info('Saved PIN: $savedPin');
    return savedPin == pin;
  }
}
