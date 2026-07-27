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
  static const String todoChannelId = 'todo_reminders';
  static const String routineChannelId = 'routine_reminders';

  // Notification IDs (base IDs, actual IDs will be offset)
  static const int mealNotificationId = 1000;
  static const int learningNotificationId = 2000;
  static const int calendarNotificationId = 3000;
  static const int encouragementNotificationId = 4000;
  // Recurring todos/routines get a block of ids each, computed from the doc
  // id: base + (seed % 10000) * 20 + (weekday-1) * 2 + kind (0=day-of,1=advance).
  static const int todoNotificationBase = 500000;
  static const int routineNotificationBase = 700000;

  // Settings keys
  static const String keyMealRemindersEnabled = 'notification_meal_enabled';
  static const String keyLearningRemindersEnabled = 'notification_learning_enabled';
  static const String keyCalendarRemindersEnabled = 'notification_calendar_enabled';
  static const String keyEncouragementEnabled = 'notification_encouragement_enabled';
  static const String keyMealReminderTime = 'notification_meal_time';
  static const String keyQuietHoursStart = 'notification_quiet_start';
  static const String keyQuietHoursEnd = 'notification_quiet_end';
  // Todos / routines / calendar per-module reminders.
  static const String keyTodoRemindersEnabled = 'notification_todo_enabled';
  static const String keyRoutineRemindersEnabled = 'notification_routine_enabled';
  // Timing mode per module: 'day_of' | 'advance' | 'both'. Default 'both'.
  static const String keyTodoTiming = 'notification_todo_timing';
  static const String keyRoutineTiming = 'notification_routine_timing';
  static const String keyCalendarTiming = 'notification_calendar_timing';
  // Fixed default clock times: day-of at 8 AM, advance the evening before at 6 PM.
  static const int dayOfHour = 8;
  static const int advanceHour = 18;

  /// Initialize the notification service
  // Cached timezone diagnostic info — populated by initialize(). Surfaced
  // via debugNotificationState() so a developer can read it from the in-app
  // notification settings page. Used to diagnose the silent-scheduling-fail
  // class of bugs where zonedSchedule queues against the wrong wall clock
  // because FlutterTimezone returned a name tz.getLocation can't parse.
  String? _lastTimezoneName;
  String? _lastTimezoneError;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone. Wrapped because FlutterTimezone has been seen to
    // return non-IANA names ("EST" instead of "America/New_York") on some
    // iOS versions — tz.getLocation throws on those and the prior code let
    // the exception kill initialize(), which meant zonedSchedule was being
    // called against UTC for some users. Now we fall back to UTC explicitly
    // and surface the error via debugNotificationState() for diagnosis.
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      _lastTimezoneName = timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('[notif-service] timezone set to $timeZoneName');
    } catch (e) {
      _lastTimezoneError = e.toString();
      _lastTimezoneName ??= 'UTC (fallback)';
      debugPrint(
        '[notif-service] failed to set timezone, falling back to UTC. '
        'Scheduled notifications may fire at wrong wall-clock time. Error: $e',
      );
      // tz.local stays at default UTC. Better than crashing init.
    }

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

    // Daily encouragement is retired — clear any reminder scheduled by an
    // older build so it stops firing after this update.
    try { await cancelEncouragementNotifications(); } catch (_) {}

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

      // Todo reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          todoChannelId,
          'To-Do Reminders',
          description: 'Reminders for recurring to-dos',
          importance: Importance.high,
        ),
      );

      // Routine reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          routineChannelId,
          'Routine Reminders',
          description: 'Reminders for recurring routines',
          importance: Importance.high,
        ),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    try {
      // Handle navigation based on payload
      final String? payload = response.payload;
      if (payload != null) {
        // payload format: "type:data" e.g., "meal:breakfast" or "learning:pathId"
        // Validate payload format before processing
        if (payload.contains(':')) {
          final parts = payload.split(':');
          if (parts.length == 2) {
            final type = parts[0];
            final data = parts[1];

            // Log valid payload for debugging
            debugPrint('Notification tapped - Type: $type, Data: $data');

            // Navigation will be handled by the app based on type
            // Valid types: meal, learning, calendar, encouragement
          } else {
            debugPrint('Invalid notification payload format: $payload');
          }
        } else {
          debugPrint('Malformed notification payload (missing separator): $payload');
        }
      }
    } catch (e, stackTrace) {
      // Catch any errors to prevent app crashes
      debugPrint('Error handling notification tap: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow - just log and gracefully fail
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

  /// Schedule meal reminder.
  /// [dayOfWeek]: 0 = daily, 1 = Sunday, 2 = Monday, ... 7 = Saturday
  Future<void> scheduleDailyMealReminder({
    required int hour,
    required int minute,
    int dayOfWeek = 0,
    String? customMessage,
  }) async {
    if (!await _isSettingEnabled(keyMealRemindersEnabled)) return;
    if (await _isTimeInQuietHours(hour, minute)) {
      await cancelMealReminders();
      return;
    }

    // dayOfWeek 0 = daily (fire every day), 1-7 = specific weekday
    final bool isWeekly = dayOfWeek >= 1 && dayOfWeek <= 7;

    // Map our index (1=Sun..7=Sat) to DateTime weekday (1=Mon..7=Sun)
    // Our: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
    // Dart: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    int? dartWeekday;
    if (isWeekly) {
      dartWeekday = dayOfWeek == 1 ? DateTime.sunday : dayOfWeek - 1;
    }

    final scheduledDate = isWeekly
        ? _nextInstanceOfDayAndTime(dartWeekday!, hour, minute)
        : _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      mealNotificationId,
      '🍽️ MomRise',
      customMessage ?? 'Here\'s your reminder to meal plan for next week!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          mealChannelId,
          'Meal Reminders',
          channelDescription: isWeekly ? 'Weekly meal plan reminders' : 'Daily meal plan reminders',
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: isWeekly
          ? DateTimeComponents.dayOfWeekAndTime
          : DateTimeComponents.time,
      payload: 'meal:${isWeekly ? "weekly" : "daily"}',
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
      _toUtcTzDateTime(scheduledTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          learningChannelId,
          'Learning Reminders',
          channelDescription: 'Learning path activity reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
      _toUtcTzDateTime(reminderTime),
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'calendar:$eventId',
    );
  }

  /// Schedule a calendar notification at a specific absolute time.
  /// Used for morning briefs and immediate fallbacks. Lower-level than
  /// scheduleCalendarReminder, which always computes fireAt from minutesBefore.
  Future<void> scheduleCalendarAt({
    required int notificationId,
    required String title,
    required String body,
    required DateTime fireAt,
    String? eventId,
  }) async {
    if (!await _isSettingEnabled(keyCalendarRemindersEnabled)) return;
    if (fireAt.isBefore(DateTime.now())) return;
    if (await _isInQuietHours(fireAt)) return;

    await _notifications.zonedSchedule(
      calendarNotificationId + notificationId,
      title,
      body,
      _toUtcTzDateTime(fireAt),
      NotificationDetails(
        android: AndroidNotificationDetails(
          calendarChannelId,
          'Calendar Reminders',
          channelDescription: 'Event and task reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'calendar:$eventId',
    );
  }

  /// Cancel a specific calendar reminder
  Future<void> cancelCalendarReminder(int notificationId) async {
    await _notifications.cancel(calendarNotificationId + notificationId);
  }

  /// Schedule a full set of reminders for an event:
  ///   1. 15 minutes before (the standard "leaving soon" ping)
  ///   2. 8 AM the day of the event (a morning brief so users see what's
  ///      coming when they wake up)
  ///   3. A fallback ping ~2 minutes from now IF both of the above are
  ///      already in the past at schedule time (e.g., user is creating an
  ///      event at 4:00 PM for 4:10 PM — 15-min-before is gone, 8 AM is
  ///      gone). Without this, tight-timing events fire zero reminders.
  ///
  /// Each variant uses a different notification id derived from the base
  /// [notificationId] so cancelEventReminders can clean them up later.
  Future<void> scheduleEventReminders({
    required int notificationId,
    required String eventName,
    required DateTime eventTime,
    String? eventId,
  }) async {
    if (!await _isSettingEnabled(keyCalendarRemindersEnabled)) return;
    final now = DateTime.now();

    // Timing mode: 'day_of' (morning brief only), 'advance' (15-min-before
    // only), or 'both' (default). Mirrors the todo/routine treatment.
    final prefs = await SharedPreferences.getInstance();
    final timing = prefs.getString(keyCalendarTiming) ?? 'both';
    final wantBefore = timing == 'advance' || timing == 'both';
    final wantMorning = timing == 'day_of' || timing == 'both';

    bool scheduledBefore = false;
    bool scheduledMorning = false;

    // 1) 15 minutes before
    final beforeAt = eventTime.subtract(const Duration(minutes: 15));
    if (wantBefore && beforeAt.isAfter(now) && !(await _isInQuietHours(beforeAt))) {
      await scheduleCalendarAt(
        notificationId: notificationId,
        title: '📅 Coming Up',
        body: '$eventName in 15 minutes',
        fireAt: beforeAt,
        eventId: eventId,
      );
      scheduledBefore = true;
    }

    // 2) 8 AM morning brief on the event date. Skip if morning has passed
    //    OR if 8 AM is within 15 minutes of the event (would feel redundant).
    final morningAt = DateTime(eventTime.year, eventTime.month, eventTime.day, 8, 0);
    if (wantMorning &&
        morningAt.isAfter(now) &&
        morningAt.isBefore(eventTime.subtract(const Duration(minutes: 15))) &&
        !(await _isInQuietHours(morningAt))) {
      await scheduleCalendarAt(
        notificationId: _eventMorningId(notificationId),
        title: '☀️ Today on your calendar',
        body: '$eventName at ${_formatEventTime(eventTime)}',
        fireAt: morningAt,
        eventId: eventId,
      );
      scheduledMorning = true;
    }

    // 3) Fallback. Only if neither above is scheduled AND event is still
    //    in the future. Picks ~2 min from now to give the OS time to
    //    register without the event firing first.
    if (!scheduledBefore && !scheduledMorning && eventTime.isAfter(now)) {
      final fallbackAt = now.add(const Duration(minutes: 2));
      if (fallbackAt.isBefore(eventTime) && !(await _isInQuietHours(fallbackAt))) {
        final minutesUntil = eventTime.difference(now).inMinutes;
        await scheduleCalendarAt(
          notificationId: _eventFallbackId(notificationId),
          title: '📅 Coming Up Soon',
          body: '$eventName in about $minutesUntil minutes',
          fireAt: fallbackAt,
          eventId: eventId,
        );
      }
    }
  }

  /// Cancel all three reminder variants for an event. Safe to call even if
  /// nothing was scheduled — the plugin no-ops on unknown ids.
  Future<void> cancelEventReminders(int notificationId) async {
    await cancelCalendarReminder(notificationId);
    await cancelCalendarReminder(_eventMorningId(notificationId));
    await cancelCalendarReminder(_eventFallbackId(notificationId));
  }

  // Notification-id variants for the three reminder kinds, all derived from
  // the same base id so cancelEventReminders can find them.
  int _eventMorningId(int baseId) => (baseId ^ 0x40000000) & 0x7fffffff;
  int _eventFallbackId(int baseId) => (baseId ^ 0x20000000) & 0x7fffffff;

  // Convert a Dart DateTime (system-local) to a TZDateTime in UTC by routing
  // through DateTime.toUtc(). This bypasses the tz.local global, which has
  // been observed silently wrong on some iOS devices when FlutterTimezone
  // returns a name the tz package can't resolve. Same absolute instant
  // either way, but this version doesn't depend on tz.local being correct.
  tz.TZDateTime _toUtcTzDateTime(DateTime dt) {
    final utc = dt.toUtc();
    return tz.TZDateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
    );
  }

  /// Snapshot of notification-service runtime state for in-app debugging.
  /// Surfaced by the Notification Settings debug view so we can diagnose
  /// silent-scheduling-fail bugs without needing device logs.
  Future<Map<String, dynamic>> debugNotificationState() async {
    final pending = await _notifications.pendingNotificationRequests();
    return {
      'initialized': _isInitialized,
      'timezone_name': _lastTimezoneName ?? '(unset)',
      'timezone_error': _lastTimezoneError ?? '(none)',
      'tz_local_now': tz.TZDateTime.now(tz.local).toString(),
      'dart_now_local': DateTime.now().toString(),
      'dart_now_utc': DateTime.now().toUtc().toString(),
      'pending_count': pending.length,
      'pending': pending
          .take(20)
          .map((p) => {
                'id': p.id,
                'title': p.title,
                'body': p.body,
                'payload': p.payload,
              })
          .toList(),
    };
  }

  // Format a DateTime as "h:mm a" (e.g. "10:30 AM") for inclusion in
  // notification bodies. Avoids pulling in intl just for one call.
  String _formatEventTime(DateTime t) {
    final hour12 = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final minute = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $ampm';
  }

  // ============ ENCOURAGEMENT ============

  /// Daily encouragement is retired — the feature is hidden app-wide, so this
  /// never schedules and always clears any previously-scheduled reminder.
  Future<void> scheduleDailyEncouragement({
    required int hour,
    required int minute,
  }) async {
    await cancelEncouragementNotifications();
    return;
    // ignore: dead_code
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
      const NotificationDetails(
        android: AndroidNotificationDetails(
          encouragementChannelId,
          'Daily Encouragement',
          channelDescription: 'Inspirational messages and tips',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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

  // ============ TODO / ROUTINE RECURRING REMINDERS ============

  /// Schedule a weekly-repeating reminder on [weekday] (1=Mon..7=Sun) at
  /// [hour]:00, repeating every week via dayOfWeekAndTime matching.
  Future<void> _scheduleWeekly({
    required int id,
    required int weekday,
    required int hour,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required String payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDayAndTime(weekday, hour, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  int _itemBaseId(bool routine, String docId) {
    final seed = docId.hashCode.abs() % 10000;
    return (routine ? routineNotificationBase : todoNotificationBase) + seed * 20;
  }

  /// (Re)schedule reminders for a set of recurring items in one module.
  /// [items] is a list of {id: String, title: String, days: List<int>}.
  /// Always cancels each item's id block first, then reschedules per the
  /// module's enable flag and timing mode ('day_of' | 'advance' | 'both').
  /// Note: fires weekly on each recurrence weekday — the every-N-weeks
  /// interval isn't reflected in the reminder (item still shows correctly
  /// in-app; a skipped week just gets an extra ping).
  Future<void> syncRecurringReminders({
    required bool routine,
    required List<Map<String, dynamic>> items,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(
            routine ? keyRoutineRemindersEnabled : keyTodoRemindersEnabled) ??
        true;
    final timing =
        prefs.getString(routine ? keyRoutineTiming : keyTodoTiming) ?? 'both';
    final channelId = routine ? routineChannelId : todoChannelId;
    final channelName = routine ? 'Routine Reminders' : 'To-Do Reminders';
    final wantDayOf = timing == 'day_of' || timing == 'both';
    final wantAdvance = timing == 'advance' || timing == 'both';

    for (final item in items) {
      final docId = item['id'] as String? ?? '';
      final title = (item['title'] as String? ?? '').trim();
      final days = ((item['days'] as List?) ?? const [])
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .where((d) => d >= 1 && d <= 7)
          .toList();
      if (docId.isEmpty) continue;
      final base = _itemBaseId(routine, docId);

      // Cancel this item's whole id block (7 weekdays × 2 kinds) first.
      for (int w = 1; w <= 7; w++) {
        await _notifications.cancel(base + (w - 1) * 2 + 0);
        await _notifications.cancel(base + (w - 1) * 2 + 1);
      }
      if (!enabled || days.isEmpty || title.isEmpty) continue;

      for (final w in days) {
        if (wantDayOf) {
          await _scheduleWeekly(
            id: base + (w - 1) * 2 + 0,
            weekday: w,
            hour: dayOfHour,
            channelId: channelId,
            channelName: channelName,
            title: routine ? '🔁 Routine' : '✅ To-Do',
            body: title,
            payload: '${routine ? 'routine' : 'todo'}:$docId',
          );
        }
        if (wantAdvance) {
          final advWeekday = w == 1 ? 7 : w - 1; // evening before
          await _scheduleWeekly(
            id: base + (w - 1) * 2 + 1,
            weekday: advWeekday,
            hour: advanceHour,
            channelId: channelId,
            channelName: channelName,
            title: routine ? '🔁 Tomorrow\'s routine' : '✅ Tomorrow',
            body: title,
            payload: '${routine ? 'routine' : 'todo'}:$docId',
          );
        }
      }
    }
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

  /// Get next instance of a specific time (for daily scheduling). Uses Dart's
  /// system-local DateTime then routes through _toUtcTzDateTime so we don't
  /// depend on tz.local being correctly set.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return _toUtcTzDateTime(scheduled);
  }

  /// Get next instance of a specific weekday and time (for weekly scheduling).
  /// [weekday] uses Dart convention: 1=Monday ... 7=Sunday.
  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return _toUtcTzDateTime(scheduled);
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
      const NotificationDetails(
        android: AndroidNotificationDetails(
          mealChannelId,
          'Meal Reminders',
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
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
