import 'package:flutter/material.dart';
import 'package:hello_nitr/core/services/api/local/local_storage_service.dart';
import 'package:hello_nitr/screens/pin/create/pin_creation_screen.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('NavigationUtil');

Future<void> navigateToPinOrHome(BuildContext context) async {
  try {
    final pin = await LocalStorageService.getPin();
    if (pin != null) {
      Navigator.pushReplacementNamed(context, '/home');
      _logger.info('Navigated to home screen');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinCreationScreen(),
        ),
      );
      _logger.info('Navigated to PIN creation screen');
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while retrieving PIN. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    _logger.severe('Error retrieving PIN: $e');
  }
}
