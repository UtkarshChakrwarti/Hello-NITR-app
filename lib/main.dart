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
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}
