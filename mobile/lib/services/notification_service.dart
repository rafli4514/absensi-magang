import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // [TAMBAHAN] Request permission untuk Android
    await _requestAndroidPermission();
  }

  // Tambahkan method ini
  Future<void> _requestAndroidPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // Menampilkan notifikasi instan
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'attendance_channel',
      'Attendance Notifications',
      channelDescription: 'Notifications for attendance updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Menjadwalkan notifikasi
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      // 3. Konversi waktu
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'reminder_channel',
        'Reminder Notifications',
        channelDescription: 'Scheduled reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 4. Panggil zonedSchedule
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Batalkan notifikasi spesifik
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Jadwal Harian
  Future<void> scheduleDailyReminders() async {
    try {
      final now = DateTime.now();

      // Jadwal Pagi (07:45)
      var clockInTime = DateTime(now.year, now.month, now.day, 7, 45);
      if (clockInTime.isBefore(now)) {
        clockInTime = clockInTime.add(const Duration(days: 1));
      }

      await scheduleNotification(
        id: 1,
        title: 'Clock In Reminder',
        body: 'Jangan lupa absen masuk!',
        scheduledTime: clockInTime,
      );

      // Jadwal Sore (16:45)
      var clockOutTime = DateTime(now.year, now.month, now.day, 16, 45);
      if (clockOutTime.isBefore(now)) {
        clockOutTime = clockOutTime.add(const Duration(days: 1));
      }

      await scheduleNotification(
        id: 2,
        title: 'Clock Out Reminder',
        body: 'Waktunya absen pulang sebentar lagi!',
        scheduledTime: clockOutTime,
      );

      print("✅ Daily reminders scheduled");
    } catch (e) {
      print("❌ Failed to schedule daily reminders: $e");
    }
  }
}
