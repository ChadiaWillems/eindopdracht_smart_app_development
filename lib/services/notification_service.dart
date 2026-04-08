import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      // We halen de ruwe tekst op (bijv: "TimezoneInfo(Europe/Brussels, ...)")
      final String rawInfo = (await FlutterTimezone.getLocalTimezone())
          .toString();

      // We knippen alles tussen de haakjes uit om "Europe/Brussels" te krijgen
      // We splitsen op '(' en pakken het tweede deel, dan splitsen we op ',' en pakken het eerste deel
      final String timeZoneName = rawInfo.split('(')[1].split(',')[0].trim();

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("Tijdzone succesvol ingesteld op: $timeZoneName");
    } catch (e) {
      print("Fout bij parsing, gebruik fallback: $e");
      // De allerbeste fallback voor jou:
      tz.setLocalLocation(tz.getLocation('Europe/Brussels'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [],
        );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Handmatig toestemming vragen voor iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required String timeStr,
  }) async {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Als de tijd vandaag al is geweest, plan hem in voor morgen
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true, // Banner in voorgrond
          presentSound: true, // Geluid in voorgrond
          presentBadge: true, // Badge in voorgrond
          interruptionLevel:
              InterruptionLevel.active, // Zorgt voor directe pop-up
        ),
        android: AndroidNotificationDetails(
          'med_reminders',
          'Medicatie Herinneringen',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'med_payload',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("Melding '$title' gepland voor: $scheduledDate"); // Debug check
  }

  Future<void> cancelAll() async => await _notifications.cancelAll();
}
