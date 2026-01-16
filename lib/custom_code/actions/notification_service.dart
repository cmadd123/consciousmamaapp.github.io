import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Notification Service for Conscious Mama
/// Handles meal reminders, learning path tasks, calendar events, and encouragement
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification channel IDs
  static const String mealChannelId = 'meal_reminders';
  static const String learningChannelId = 'learning_reminders';
  static const String calendarChannelId = 'calendar_reminders';
  static const String encouragementChannelId = 'encouragement';

  // Notification IDs (base IDs, actual IDs will be offset)
  static const int mealNotificationId = 1000;
  static const int learningNotificationId = 2000;
  static const int calendarNotificationId = 3000;
  static const int encouragementNotificationId = 4000;

  // Settings keys
  static const String keyMealRemindersEnabled = 'notification_meal_enabled';
  static const String keyLearningRemindersEnabled = 'notification_learning_enabled';
  static const String keyCalendarRemindersEnabled = 'notification_calendar_enabled';
  static const String keyEncouragementEnabled = 'notification_encouragement_enabled';
  static const String keyMealReminderTime = 'notification_meal_time';
  static const String keyQuietHoursStart = 'notification_quiet_start';
  static const String keyQuietHoursEnd = 'notification_quiet_end';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Meal reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          mealChannelId,
          'Meal Reminders',
          description: 'Daily meal plan reminders',
          importance: Importance.high,
        ),
      );

      // Learning reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          learningChannelId,
          'Learning Reminders',
          description: 'Learning path activity reminders',
          importance: Importance.high,
        ),
      );

      // Calendar reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          calendarChannelId,
          'Calendar Reminders',
          description: 'Event and task reminders',
          importance: Importance.high,
        ),
      );

      // Encouragement channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          encouragementChannelId,
          'Daily Encouragement',
          description: 'Inspirational messages and tips',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
    final String? payload = response.payload;
    if (payload != null) {
      // payload format: "type:data" e.g., "meal:breakfast" or "learning:pathId"
      // Navigation will be handled by the app
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  /// Request notification permissions (call on first app launch or from settings)
  Future<bool> requestPermissions() async {
    // Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? false;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }

    return true; // Assume enabled for iOS
  }

  // ============ MEAL REMINDERS ============

  /// Schedule daily meal reminder
  Future<void> scheduleDailyMealReminder({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    if (!await _isSettingEnabled(keyMealRemindersEnabled)) return;

    await _notifications.zonedSchedule(
      mealNotificationId,
      '🍽️ Today\'s Meal Plan',
      customMessage ?? 'Check out what\'s cooking today!',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          mealChannelId,
          'Meal Reminders',
          channelDescription: 'Daily meal plan reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'meal:daily',
    );
  }

  /// Cancel meal reminders
  Future<void> cancelMealReminders() async {
    await _notifications.cancel(mealNotificationId);
  }

  // ============ LEARNING PATH REMINDERS ============

  /// Schedule a learning path task reminder
  Future<void> scheduleLearningTaskReminder({
    required int notificationId,
    required String taskName,
    required String childName,
    required DateTime scheduledTime,
    String? learningPathId,
  }) async {
    if (!await _isSettingEnabled(keyLearningRemindersEnabled)) return;
    if (await _isInQuietHours(scheduledTime)) return;

    await _notifications.zonedSchedule(
      learningNotificationId + notificationId,
      '📚 Learning Time for $childName!',
      taskName,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          learningChannelId,
          'Learning Reminders',
          channelDescription: 'Learning path activity reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'learning:$learningPathId',
    );
  }

  /// Cancel a specific learning task reminder
  Future<void> cancelLearningTaskReminder(int notificationId) async {
    await _notifications.cancel(learningNotificationId + notificationId);
  }

  /// Cancel all learning reminders
  Future<void> cancelAllLearningReminders() async {
    // Cancel a range of IDs
    for (int i = 0; i < 100; i++) {
      await _notifications.cancel(learningNotificationId + i);
    }
  }

  // ============ CALENDAR REMINDERS ============

  /// Schedule a calendar event reminder
  Future<void> scheduleCalendarReminder({
    required int notificationId,
    required String eventName,
    required DateTime eventTime,
    int minutesBefore = 15,
    String? eventId,
  }) async {
    if (!await _isSettingEnabled(keyCalendarRemindersEnabled)) return;

    final reminderTime = eventTime.subtract(Duration(minutes: minutesBefore));
    if (reminderTime.isBefore(DateTime.now())) return;
    if (await _isInQuietHours(reminderTime)) return;

    await _notifications.zonedSchedule(
      calendarNotificationId + notificationId,
      '📅 Coming Up',
      '$eventName in $minutesBefore minutes',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          calendarChannelId,
          'Calendar Reminders',
          channelDescription: 'Event and task reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'calendar:$eventId',
    );
  }

  /// Cancel a specific calendar reminder
  Future<void> cancelCalendarReminder(int notificationId) async {
    await _notifications.cancel(calendarNotificationId + notificationId);
  }

  // ============ ENCOURAGEMENT ============

  /// Schedule daily encouragement notification
  Future<void> scheduleDailyEncouragement({
    required int hour,
    required int minute,
  }) async {
    if (!await _isSettingEnabled(keyEncouragementEnabled)) return;

    final messages = [
      'You\'re doing an amazing job, mama! 💪',
      'Every small step counts. Keep going! ✨',
      'Your love shapes their world. 💕',
      'Take a moment to breathe. You\'ve got this! 🌸',
      'Progress, not perfection. You\'re enough! 🌟',
    ];

    final randomMessage = messages[DateTime.now().day % messages.length];

    await _notifications.zonedSchedule(
      encouragementNotificationId,
      '💝 Daily Encouragement',
      randomMessage,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          encouragementChannelId,
          'Daily Encouragement',
          channelDescription: 'Inspirational messages and tips',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'encouragement:daily',
    );
  }

  /// Cancel encouragement notifications
  Future<void> cancelEncouragementNotifications() async {
    await _notifications.cancel(encouragementNotificationId);
  }

  // ============ SETTINGS HELPERS ============

  /// Check if a notification setting is enabled
  Future<bool> _isSettingEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true; // Default to enabled
  }

  /// Set a notification setting
  Future<void> setSettingEnabled(String key, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, enabled);
  }

  /// Get a notification setting
  Future<bool> getSettingEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }

  /// Set quiet hours
  Future<void> setQuietHours(int startHour, int endHour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyQuietHoursStart, startHour);
    await prefs.setInt(keyQuietHoursEnd, endHour);
  }

  /// Check if a time is in quiet hours
  Future<bool> _isInQuietHours(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final startHour = prefs.getInt(keyQuietHoursStart) ?? 22; // Default 10 PM
    final endHour = prefs.getInt(keyQuietHoursEnd) ?? 7; // Default 7 AM

    final hour = time.hour;

    if (startHour > endHour) {
      // Quiet hours span midnight (e.g., 22:00 - 07:00)
      return hour >= startHour || hour < endHour;
    } else {
      // Quiet hours within same day (e.g., 01:00 - 06:00)
      return hour >= startHour && hour < endHour;
    }
  }

  /// Get next instance of a specific time (for daily scheduling)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      '🎉 Notifications Working!',
      'Conscious Mama can now send you reminders.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          mealChannelId,
          'Meal Reminders',
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

/// Global notification service instance
final notificationService = NotificationService();
