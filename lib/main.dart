import 'package:flutter/material.dart';
import 'package:hello_nitr/app.dart';
import 'package:hello_nitr/core/services/notifications/notifications_service.dart';
import 'package:hello_nitr/core/services/permissions/permissions_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request necessary permissions
  await requestPermissions();
  
  // Initialize the NotificationService
  NotificationService notificationService = NotificationService();
  await notificationService.initializeNotifications();
  await notificationService.requestNotificationPermissions(); // Request notification permissions
  
  // Schedule the update notification
  notificationService.scheduleUpdateNotification();
  
  runApp(MyApp(notificationService: notificationService));
}
