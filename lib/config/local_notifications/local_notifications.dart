import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  static Future<void> requestPermissionLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // TODO ios configuration

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // TODO IOS SETUP
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      //onDidReceiveBackgroundNotificationResponse:
      //  onDidReceiveBackgroundNotificationResponse);
    );
  }

  static void showLocalNotification(
      {required int id, String? title, String? body, String? data}) {
    const androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high);

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      // TODO IOS
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails,
        payload: data);
  }
}
