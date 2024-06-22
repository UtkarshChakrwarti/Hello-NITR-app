import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> requestPermissions() async {
  final permissions = [
    Permission.phone,
    Permission.notification, // Request notification permission
  ];

  final statuses = await permissions.request();

  statuses.forEach((permission, status) {
    if (status != PermissionStatus.granted) {
      Sentry.captureMessage('$permission not granted');
      print('$permission not granted');
    }
  });
}
