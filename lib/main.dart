import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/app.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:hello_nitr/core/services/notifications/notifications_service.dart';
import 'package:hello_nitr/core/utils/permissions/permissions_util.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  _setupLogging(); // Setup logging
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConstants.sentryDsn; // Replace with your Sentry DSN
      options.debug = kDebugMode; // Enable debug logging in debug mode
    },
    appRunner: () async {
      // Request necessary permissions
      await requestPermissions();

      // Initialize the NotificationService
      NotificationService notificationService = NotificationService();
      await notificationService.initializeNotifications();
      await notificationService.requestNotificationPermissions(); // Request notification permissions

      // Schedule the update notification
      notificationService.scheduleUpdateNotification();

      runApp(MyApp(notificationService: notificationService));
    },
  );
}

void _setupLogging() {  // Setup logging for the app only in debug mode
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((LogRecord rec) {
    if (kDebugMode) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    } else {
      Sentry.captureMessage('${rec.level.name}: ${rec.time}: ${rec.message}');
    }
  });
}
