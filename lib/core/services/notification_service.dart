import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/router.dart';
import '../../shared/models/habit_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService();

  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    String timeZoneName = 'UTC';
    try {
      final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
      final String tzInfoData = tzInfo.identifier;
      debugPrint('timezone: $tzInfoData');
      timeZoneName = tzInfoData;
    } catch (_) {
      timeZoneName = 'Asia/Jakarta';
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/Darwin Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // Initialize Plugin
    try {
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            // Push to deep-linked habit detail screen using global appRouter
            appRouter.push('/habit/detail/$payload');
          }
        },
      );

      // Request permissions for Android 13+ and Exact Alarms permission
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      // Handle app launch from notification click (cold starts)
      final NotificationAppLaunchDetails? appLaunchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (appLaunchDetails != null &&
          appLaunchDetails.didNotificationLaunchApp) {
        final payload = appLaunchDetails.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            appRouter.push('/habit/detail/$payload');
          });
        }
      }
    } catch (_) {
      // Graceful fallback for test environments or unsupported platforms
    }
  }

  Future<void> scheduleHabitReminder(HabitModel habit) async {
    // Cancel existing reminders first
    await cancelHabitReminder(habit.id);

    if (!habit.isActive || habit.activeDays.isEmpty) return;

    // Parse reminder time "HH:mm"
    final timeParts = habit.reminderTime.split(':');
    if (timeParts.length != 2) return;
    final int hour = int.tryParse(timeParts[0]) ?? 8;
    final int minute = int.tryParse(timeParts[1]) ?? 0;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'habit_reminders_channel',
          'Habit Reminders',
          channelDescription: 'Channel for habit reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    int scheduledCount = 0;
    // Schedule a reminder for each active weekday
    for (final dayStr in habit.activeDays) {
      final weekday = _mapWeekdayStringToInt(dayStr);
      final notificationId = _getNotificationId(habit.id, weekday);
      final scheduledDate = _nextInstanceOfWeekdayAndTime(
        weekday,
        hour,
        minute,
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: 'Time for ${habit.title}! 💪',
          body: 'Keep your streak alive! Let\'s do it today.',
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: habit.id,
        );
        scheduledCount++;
      } catch (e) {
        // Fallback to inexact mode if exact alarm permission is not granted
        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: 'Time for ${habit.title}! 💪',
            body: 'Keep your streak alive! Let\'s do it today.',
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: habit.id,
          );
          scheduledCount++;
        } catch (err) {
          debugPrint(
            '❌ Gagal menjadwalkan notifikasi [ID: $notificationId]: $err',
          );
        }
      }
    }

    if (scheduledCount > 0) {
      debugPrint(
        '🔔 TERJADWAL: $scheduledCount notifikasi mingguan untuk "${habit.title}" (Jam ${habit.reminderTime})',
      );
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    for (int weekday = 1; weekday <= 7; weekday++) {
      final id = _getNotificationId(habitId, weekday);
      try {
        await _notificationsPlugin.cancel(id: id);
      } catch (_) {}
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  Future<void> rescheduleAll(List<HabitModel> habits) async {
    await cancelAllReminders();
    for (final habit in habits) {
      await scheduleHabitReminder(habit);
    }
  }

  int _getNotificationId(String habitId, int weekday) {
    final int hash = habitId.hashCode.abs();
    return (hash % 100000000) * 10 + weekday;
  }

  int _mapWeekdayStringToInt(String day) {
    switch (day.toLowerCase().trim()) {
      case 'mon':
        return DateTime.monday;
      case 'tue':
        return DateTime.tuesday;
      case 'wed':
        return DateTime.wednesday;
      case 'thu':
        return DateTime.thursday;
      case 'fri':
        return DateTime.friday;
      case 'sat':
        return DateTime.saturday;
      case 'sun':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(
    int weekday,
    int hour,
    int minute,
  ) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
