import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../calendar/enoch_calendar.dart';
import 'calendar_reminder_schedule.dart';

class SabbathReminderService {
  SabbathReminderService._();

  static final SabbathReminderService instance = SabbathReminderService._();
  static const _sabbathNotificationBaseId = 6000;
  static const _observanceNotificationBaseId = 7000;
  static const _sabbathScheduledCount = 16;
  static const _observanceScheduledCount = 36;

  final _notifications = FlutterLocalNotificationsPlugin();
  var _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized || kIsWeb) return;
    tz.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      // UTC remains a safe fallback if a device does not expose an IANA zone.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_luach'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _notifications.initialize(settings: settings);
    _isInitialized = true;
  }

  Future<bool> enable(EnochCalendar calendar) async {
    if (kIsWeb) return false;
    await _initialize();
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidAllowed = await android?.requestNotificationsPermission();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosAllowed = await ios?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    if (androidAllowed == false || iosAllowed == false) return false;
    await _scheduleUpcoming(calendar);
    return true;
  }

  Future<void> reschedule(EnochCalendar calendar) async {
    if (kIsWeb) return;
    await _initialize();
    await _scheduleUpcoming(calendar);
  }

  Future<void> disable() async {
    if (kIsWeb) return;
    await _initialize();
    for (var offset = 0; offset < _sabbathScheduledCount; offset++) {
      await _notifications.cancel(id: _sabbathNotificationBaseId + offset);
    }
    for (var offset = 0; offset < _observanceScheduledCount; offset++) {
      await _notifications.cancel(id: _observanceNotificationBaseId + offset);
    }
  }

  Future<void> _scheduleUpcoming(EnochCalendar calendar) async {
    await disable();
    final now = tz.TZDateTime.now(tz.local);
    final reminders = upcomingCalendarReminders(
      calendar,
      now,
      sabbathLimit: _sabbathScheduledCount,
      observanceLimit: _observanceScheduledCount,
    );
    var sabbathOffset = 0;
    var observanceOffset = 0;
    for (final reminder in reminders) {
      final scheduledAt = tz.TZDateTime(
        tz.local,
        reminder.scheduledAt.year,
        reminder.scheduledAt.month,
        reminder.scheduledAt.day,
        reminder.scheduledAt.hour,
      );
      final isSabbath = reminder.kind == CalendarReminderKind.sabbath;
      await _notifications.zonedSchedule(
        id: isSabbath
            ? _sabbathNotificationBaseId + sabbathOffset++
            : _observanceNotificationBaseId + observanceOffset++,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: scheduledAt,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            isSabbath ? 'sabbath_reminders' : 'calendar_observances',
            isSabbath ? 'Sabbath reminders' : 'Calendar observances',
            channelDescription: isSabbath
                ? 'Reminders for upcoming Enoch Sabbaths.'
                : 'Reference observances in Luach Chanoch.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
