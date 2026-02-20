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
    if (await _isTimeInQuietHours(hour, minute)) {
      await cancelMealReminders();
      return;
    }

    await _notifications.zonedSchedule(
      mealNotificationId,
      '🍽️ MomRise',
      customMessage ?? 'Here\'s your reminder to meal plan for next week!',
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
    if (await _isTimeInQuietHours(hour, minute)) {
      await cancelEncouragementNotifications();
      return;
    }

    final messages = [
      'She is clothed with strength and dignity, and she laughs without fear of the future. — Proverbs 31:25',
      'Her children rise up and call her blessed; her husband also, and he praises her. — Proverbs 31:28',
      'Train up a child in the way he should go, and when he is old he will not depart from it. — Proverbs 22:6',
      'The wise woman builds her house, but the foolish pulls it down with her hands. — Proverbs 14:1',
      'Be strong and courageous. Do not be afraid, for the Lord your God is with you wherever you go. — Joshua 1:9',
      'I can do all things through Christ who strengthens me. — Philippians 4:13',
      'Cast all your anxiety on Him, because He cares for you. — 1 Peter 5:7',
      'The Lord is my strength and my shield; my heart trusts in Him, and He helps me. — Psalm 28:7',
      'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you. — Jeremiah 29:11',
      'Be still, and know that I am God. — Psalm 46:10',
      'Let us not grow weary in doing good, for in due season we will reap if we do not give up. — Galatians 6:9',
      'Trust in the Lord with all your heart, and lean not on your own understanding. — Proverbs 3:5',
      'The Lord will fight for you; you need only to be still. — Exodus 14:14',
      'Come to me, all you who are weary and burdened, and I will give you rest. — Matthew 11:28',
      'She opens her mouth with wisdom, and the teaching of kindness is on her tongue. — Proverbs 31:26',
      'Do not be anxious about anything, but in everything by prayer, present your requests to God. — Philippians 4:6',
      'He gives strength to the weary and increases the power of the weak. — Isaiah 40:29',
      'The joy of the Lord is your strength. — Nehemiah 8:10',
      'A mother\'s heart is a child\'s classroom. — Henry Ward Beecher',
      'God could not be everywhere, and therefore He made mothers. — Rudyard Kipling',
      'The influence of a mother upon the lives of her children cannot be measured. — Billy Graham',
      'A good mother is worth a hundred teachers. — George Herbert',
      'Motherhood is a great honor and privilege. — Elisabeth Elliot',
      'The hand that rocks the cradle rules the world. — William Ross Wallace',
      'There is no way to be a perfect mother, but a million ways to be a good one. — Jill Churchill',
      'When you feel like giving up, remember who is watching. Your children learn strength from you.',
      'Your home is your ministry. The small, faithful work you do each day matters to God.',
      'Rest when you need to, mama. Even God rested on the seventh day.',
      'You were chosen for these children. God knew exactly what He was doing.',
      'A gentle answer turns away wrath. Let grace lead your home today. — Proverbs 15:1',
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

  /// Check if a given hour:minute falls within quiet hours
  Future<bool> _isTimeInQuietHours(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    final startHour = prefs.getInt(keyQuietHoursStart) ?? 22;
    final startMinute = prefs.getInt('${keyQuietHoursStart}_minute') ?? 0;
    final endHour = prefs.getInt(keyQuietHoursEnd) ?? 7;
    final endMinute = prefs.getInt('${keyQuietHoursEnd}_minute') ?? 0;

    final timeMinutes = hour * 60 + minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (startMinutes > endMinutes) {
      return timeMinutes >= startMinutes || timeMinutes < endMinutes;
    } else {
      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
    }
  }

  /// Check if a DateTime is in quiet hours
  Future<bool> _isInQuietHours(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final startHour = prefs.getInt(keyQuietHoursStart) ?? 22;
    final startMinute = prefs.getInt('${keyQuietHoursStart}_minute') ?? 0;
    final endHour = prefs.getInt(keyQuietHoursEnd) ?? 7;
    final endMinute = prefs.getInt('${keyQuietHoursEnd}_minute') ?? 0;

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (startMinutes > endMinutes) {
      // Quiet hours span midnight (e.g., 22:30 - 07:00)
      return timeMinutes >= startMinutes || timeMinutes < endMinutes;
    } else {
      // Quiet hours within same day (e.g., 01:00 - 06:00)
      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
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
      'MomRise can now send you reminders.',
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
