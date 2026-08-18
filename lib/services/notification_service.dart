import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleFeeReminder({
    required int id,
    required DateTime dateTime,
    required String studentName,
    required double dueAmount,
  }) async {
    final scheduled = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'fee_reminders',
        'Fee reminders',
        channelDescription: 'Local reminders for pending school fees.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      'Fee reminder',
      '$studentName has pending fee of ₹${dueAmount.toStringAsFixed(0)}.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'fee:$studentName',
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
