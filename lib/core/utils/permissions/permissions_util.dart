import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('PermissionHandler');

Future<void> requestPermissions() async {
  final permissions = [
    Permission.phone,
    Permission.notification,
  ];

  try {
    final statuses = await permissions.request();

    statuses.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        final message = '$permission not granted';
        Sentry.captureMessage(message);
        _logger.warning(message);
      }
    });
  } catch (e, stackTrace) {
    Sentry.captureException(e, stackTrace: stackTrace);
    _logger.severe('Error requesting permissions: $e');
  }
}
