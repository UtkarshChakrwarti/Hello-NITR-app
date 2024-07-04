import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/app.dart';
import 'package:hello_nitr/core/services/notifications/notifications_service.dart';
import 'package:hello_nitr/core/utils/permissions/permissions_util.dart';
import 'package:logging/logging.dart';

void main() async {
  _setupLogging(); // Setup logging
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions
  await requestPermissions();

  // Initialize the NotificationService
  NotificationService notificationService = NotificationService();
  await notificationService.initializeNotifications();
  await notificationService
      .requestNotificationPermissions(); // Request notification permissions

  // Schedule the update notification
  notificationService.scheduleUpdateNotification();

  runApp(MyApp(notificationService: notificationService));
}

void _setupLogging() {
  // Setup logging for the app only in debug mode
  Logger.root.onRecord.listen((LogRecord rec) {
    if (kDebugMode) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    }
  });
}
