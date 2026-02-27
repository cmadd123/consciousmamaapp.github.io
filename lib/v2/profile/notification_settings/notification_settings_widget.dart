import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  static String routeName = 'notificationSettings';
  static String routePath = '/notificationSettings';

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _mealReminders = true;
  bool _learningReminders = true;
  bool _calendarReminders = true;
  bool _encouragement = true;
  TimeOfDay _mealReminderTime = const TimeOfDay(hour: 7, minute: 0);
  int _mealReminderDay = 0; // 0 = Sunday, 1 = Monday, etc. (0 = daily for now)
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);
  bool _isLoading = true;
  bool _notificationsPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Check permission status
    _notificationsPermissionGranted =
        await actions.notificationService.areNotificationsEnabled();

    setState(() {
      _mealReminders = prefs.getBool(actions.NotificationService.keyMealRemindersEnabled) ?? true;
      _learningReminders = prefs.getBool(actions.NotificationService.keyLearningRemindersEnabled) ?? true;
      _calendarReminders = prefs.getBool(actions.NotificationService.keyCalendarRemindersEnabled) ?? true;
      _encouragement = prefs.getBool(actions.NotificationService.keyEncouragementEnabled) ?? true;

      final mealHour = prefs.getInt(actions.NotificationService.keyMealReminderTime) ?? 7;
      final mealMinute = prefs.getInt('${actions.NotificationService.keyMealReminderTime}_minute') ?? 0;
      _mealReminderTime = TimeOfDay(hour: mealHour, minute: mealMinute);
      _mealReminderDay = prefs.getInt('${actions.NotificationService.keyMealReminderTime}_day') ?? 0;

      final quietStartHour = prefs.getInt(actions.NotificationService.keyQuietHoursStart) ?? 22;
      final quietStartMinute = prefs.getInt('${actions.NotificationService.keyQuietHoursStart}_minute') ?? 0;
      final quietEndHour = prefs.getInt(actions.NotificationService.keyQuietHoursEnd) ?? 7;
      final quietEndMinute = prefs.getInt('${actions.NotificationService.keyQuietHoursEnd}_minute') ?? 0;
      _quietStart = TimeOfDay(hour: quietStartHour, minute: quietStartMinute);
      _quietEnd = TimeOfDay(hour: quietEndHour, minute: quietEndMinute);

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(actions.NotificationService.keyMealRemindersEnabled, _mealReminders);
    await prefs.setBool(actions.NotificationService.keyLearningRemindersEnabled, _learningReminders);
    await prefs.setBool(actions.NotificationService.keyCalendarRemindersEnabled, _calendarReminders);
    await prefs.setBool(actions.NotificationService.keyEncouragementEnabled, _encouragement);
    await prefs.setInt(actions.NotificationService.keyMealReminderTime, _mealReminderTime.hour);
    await prefs.setInt('${actions.NotificationService.keyMealReminderTime}_minute', _mealReminderTime.minute);
    await prefs.setInt('${actions.NotificationService.keyMealReminderTime}_day', _mealReminderDay);
    await prefs.setInt(actions.NotificationService.keyQuietHoursStart, _quietStart.hour);
    await prefs.setInt('${actions.NotificationService.keyQuietHoursStart}_minute', _quietStart.minute);
    await prefs.setInt(actions.NotificationService.keyQuietHoursEnd, _quietEnd.hour);
    await prefs.setInt('${actions.NotificationService.keyQuietHoursEnd}_minute', _quietEnd.minute);

    // Update scheduled notifications
    if (_mealReminders) {
      await actions.notificationService.scheduleDailyMealReminder(
        hour: _mealReminderTime.hour,
        minute: _mealReminderTime.minute,
        dayOfWeek: _mealReminderDay,
      );
    } else {
      await actions.notificationService.cancelMealReminders();
    }

    if (_encouragement) {
      await actions.notificationService.scheduleDailyEncouragement(
        hour: 8,
        minute: 0,
      );
    } else {
      await actions.notificationService.cancelEncouragementNotifications();
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await actions.notificationService.requestPermissions();
    setState(() {
      _notificationsPermissionGranted = granted;
    });

    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications enabled!'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      );
    }
  }

  Future<void> _selectTime(String type) async {
    TimeOfDay initialTime;
    switch (type) {
      case 'meal':
        initialTime = _mealReminderTime;
        break;
      case 'quietStart':
        initialTime = _quietStart;
        break;
      case 'quietEnd':
        initialTime = _quietEnd;
        break;
      default:
        initialTime = const TimeOfDay(hour: 7, minute: 0);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FlutterFlowTheme.of(context).primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        switch (type) {
          case 'meal':
            _mealReminderTime = picked;
            break;
          case 'quietStart':
            _quietStart = picked;
            break;
          case 'quietEnd':
            _quietEnd = picked;
            break;
        }
      });
      await _saveSettings();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Notifications',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: FlutterFlowTheme.of(context).primary,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Permission banner if not granted
                    if (!_notificationsPermissionGranted)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 32.0,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Enable Notifications',
                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Andika New Basic',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Allow notifications to receive meal reminders, learning prompts, and encouragement.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 12.0),
                            FFButtonWidget(
                              onPressed: _requestPermissions,
                              text: 'Enable',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // All settings wrapped in Opacity when permissions not granted
                    Opacity(
                      opacity: _notificationsPermissionGranted ? 1.0 : 0.4,
                      child: IgnorePointer(
                        ignoring: !_notificationsPermissionGranted,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section: Reminders
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                              child: Text(
                                'Reminders',
                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),

                            // Meal Reminders
                            _buildSettingTile(
                              icon: Icons.restaurant_menu,
                              title: 'Remind me to plan meals:',
                              value: _mealReminders,
                              onChanged: (value) async {
                                setState(() => _mealReminders = value);
                                await _saveSettings();
                              },
                            ),

                            // Meal reminder time
                            if (_mealReminders) ...[
                              _buildTimeTile(
                                title: 'Reminder Time',
                                time: _mealReminderTime,
                                onTap: () => _selectTime('meal'),
                              ),
                              _buildDayOfWeekTile(),
                            ],

                            // Learning Reminders
                            _buildSettingTile(
                              icon: Icons.school_outlined,
                              title: 'Learning Reminders',
                              subtitle: 'Reminders for learning path activities',
                              value: _learningReminders,
                              onChanged: (value) async {
                                setState(() => _learningReminders = value);
                                await _saveSettings();
                              },
                            ),

                            // Calendar Reminders
                            _buildSettingTile(
                              icon: Icons.calendar_today_outlined,
                              title: 'Calendar Reminders',
                              subtitle: 'Alerts before scheduled events',
                              value: _calendarReminders,
                              onChanged: (value) async {
                                setState(() => _calendarReminders = value);
                                await _saveSettings();
                              },
                            ),

                            // Encouragement
                            _buildSettingTile(
                              icon: Icons.favorite_outline,
                              title: 'Daily Encouragement',
                              subtitle: 'Inspirational messages to brighten your day',
                              value: _encouragement,
                              onChanged: (value) async {
                                setState(() => _encouragement = value);
                                await _saveSettings();
                              },
                            ),

                            const SizedBox(height: 16.0),

                            // Section: Quiet Hours
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                              child: Text(
                                'Quiet Hours',
                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'No notifications will be sent during these hours',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),

                            _buildTimeTile(
                              title: 'Start',
                              time: _quietStart,
                              onTap: () => _selectTime('quietStart'),
                            ),

                            _buildTimeTile(
                              title: 'End',
                              time: _quietEnd,
                              onTap: () => _selectTime('quietEnd'),
                            ),

                            const SizedBox(height: 24.0),

                            // Test notification button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  await actions.notificationService.showTestNotification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Test notification sent!'),
                                      backgroundColor: FlutterFlowTheme.of(context).primary,
                                    ),
                                  );
                                },
                                text: 'Send Test Notification',
                                icon: Icon(
                                  Icons.notifications_active_outlined,
                                  size: 20.0,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50.0,
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context).primaryText,
                                        letterSpacing: 0.0,
                                      ),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80.0),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: ListTile(
          leading: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
          ),
          title: Text(
            title,
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'Andika New Basic',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                )
              : null,
          trailing: Switch(
            value: value,
            onChanged: _notificationsPermissionGranted ? onChanged : null,
            activeColor: FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      letterSpacing: 0.0,
                    ),
              ),
              Row(
                children: [
                  Text(
                    _formatTime(time),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8.0),
                  Icon(
                    Icons.chevron_right,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 20.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayOfWeekTile() {
    final days = ['Daily', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Day',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(days.length, (index) {
                final isSelected = _mealReminderDay == index;
                return InkWell(
                  onTap: () async {
                    setState(() => _mealReminderDay = index);
                    await _saveSettings();
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected
                            ? FlutterFlowTheme.of(context).primary
                            : FlutterFlowTheme.of(context).alternate,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      days[index],
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: isSelected
                                ? Colors.white
                                : FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
