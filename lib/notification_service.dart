import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

    // Check and request exact alarm permission for Android 12+
    static Future<void> checkExactAlarmPermission() async {
      if (Platform.isAndroid) {
        try {
          final int sdkVersion = int.parse(Platform.version.split('.')[0]);

          if (sdkVersion >= 12) {
            if (!(await Permission.scheduleExactAlarm.isGranted)) {
              var requestResult = await Permission.scheduleExactAlarm.request();
              if (!requestResult.isGranted) {
                print("Exact alarm permission not granted. Redirecting to settings.");
                openAppSettings();
              }
            }
          }
        } catch (e) {
          print("Error checking exact alarm permission: $e");
        }
      }
    }


  // Initialize the notification service
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);

    // Check and request exact alarm permission
    await checkExactAlarmPermission();
  }

  // Schedule a notification with exact time
  static Future<void> scheduleNotification(
    int id, String title, String body, DateTime scheduleTime) async {
    await checkExactAlarmPermission();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'This channel is used for task notifications',
      importance: Importance.max,
      priority: Priority.high, // Ensures the notification pops up
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
}


  // Cancel a notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
