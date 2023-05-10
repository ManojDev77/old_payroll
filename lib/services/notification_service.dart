import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;

//import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future init({initScheduled = false}) async {
    const android = AndroidInitializationSettings('ic_launcher');
    const ios = IOSInitializationSettings();
    const initializationSettings =
        InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      onNotification.add(payload);
    });
  }

  static Future showNoti({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.show(id, title, body, await notificationDetails());
  }

  static Future showNotificationSchedule({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      _notifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduletime(scheduleDate), tz.local),
          await notificationDetails(),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

  static DateTime scheduletime(DateTime schedule) {
    final now = DateTime.now().toLocal();

    final scheduleDate = DateTime(now.year, now.month, now.day, schedule.hour,
        schedule.minute, schedule.second);
    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }

  static Future notificationDetails() async {
    // const sound = 'soundalarm.wav';
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channelName',
          channelDescription: 'your other channel description',
          importance: Importance.max,
          channelShowBadge: true,
          priority: Priority.high,
          enableVibration: true,
          // playSound: true,
          // sound: RawResourceAndroidNotificationSound('soundalarm'),
        ),
        iOS: IOSNotificationDetails(
            // sound: sound,
            ));
  }

  static void cancel() => _notifications.cancelAll();
  static void cancelById(id) => _notifications.cancel(id);
}
