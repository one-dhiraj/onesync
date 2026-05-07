import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationDisplayService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings: settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'onesync_channel',
      'OneSync Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}

Future<bool> isNotificationAllowed() async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();

  return settings.authorizationStatus == AuthorizationStatus.authorized;
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission();

  return settings.authorizationStatus == AuthorizationStatus.authorized;
}

Future<bool> checkNotificationDisplayPermission() async {
  bool permission = await isNotificationAllowed();
  if (!permission) {
    permission = await requestNotificationPermission();
  }
  return permission;
}
