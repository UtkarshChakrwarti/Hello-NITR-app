import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
          String? payload = notificationResponse.payload;
          if (payload != null && await canLaunch(payload)) {
            await launch(payload);
          } else {
            print('Could not launch $payload');
          }
        },
      );

      // Request notification permissions
      await requestNotificationPermissions();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    try {
      PermissionStatus status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        print('Notification permission not granted');
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel_id',
    String channelName = 'default_channel_name',
    String channelDescription = 'Default Channel',
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
      color: AppColors.primaryColor,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
      enableVibration: true,
      playSound: true,
      actions: [
        AndroidNotificationAction(
          'update_action',
          'Update Now',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> scheduleUpdateNotification() async {
    try {
      // Check for app update
      bool isUpdateAvailable = true; // Replace with actual update check logic

      if (isUpdateAvailable) {
        await showNotification(
          title: 'Update Available',
          body:
              'A new version of Hello NITR is available. Update now to get the latest features and improvements.',
          payload: AppConstants.playStoreUrl, // Replace with your app's URL
          channelId: 'update_channel_id',
          channelName: 'Update Notifications',
          channelDescription: 'Notifications for app updates',
        );
      }
    } catch (e) {
      print('Error scheduling update notification: $e');
    }
  }
}