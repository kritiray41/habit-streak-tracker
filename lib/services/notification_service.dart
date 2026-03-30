import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Android Setup
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. iOS Setup
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    // 3. Linux Setup (For your Pop!_OS desktop!)
    const LinuxInitializationSettings initializationSettingsLinux = 
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Combine all platform settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );

    // FIX: Use named argument "settings:" for the new package version
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  // Method to trigger an immediate test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_channel', 
      'Habit Reminders',
      channelDescription: 'Notifications for daily habit reminders',
      importance: Importance.max, 
      priority: Priority.high,
    );
    
    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      linux: linuxDetails,
    );

    // FIX: Use named arguments for the new package version
    await _notificationsPlugin.show(
      id: 0, 
      title: 'Habit Streak 🔥', 
      body: 'Notifications are working! Time to crush your goals.', 
      notificationDetails: platformDetails,
    );
  }
}