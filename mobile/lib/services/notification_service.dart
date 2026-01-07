import 'dart:ui'; // Diperlukan untuk Color jika AppThemes belum meloadnya

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../themes/app_themes.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // Pastikan icon 'ic_notification' atau '@mipmap/ic_launcher' ada
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    // Request permission (Android 13+)
    await _requestAndroidPermission();

    _isInitialized = true;
  }

  Future<void> _requestAndroidPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // --- 1. NOTIFIKASI STANDARD ---
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Menggunakan warna Primary dari AppThemes
    final color = AppThemes.primaryColor;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'status_channel',
      'Status Updates',
      channelDescription: 'Notifikasi perubahan status izin/logbook',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: color, // Warna dari tema
      styleInformation: const BigTextStyleInformation(''),
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // --- 2. NOTIFIKASI ALERT (URGENT / LUPA ABSEN) ---
  Future<void> showUrgentNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Menggunakan warna Error dari AppThemes
    final Color alertColor = AppThemes.errorColor;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'urgent_channel',
      'Urgent Alerts',
      channelDescription: 'Peringatan penting seperti lupa absen',
      importance: Importance.max,
      priority: Priority.max,
      color: alertColor, // Warna merah dari tema
      enableVibration: true,
      playSound: true,
    );

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // --- 3. SCHEDULE REMINDERS (JADWAL HARIAN) ---
  Future<void> scheduleDailyReminders() async {
    try {
      final now = DateTime.now();

      // Jadwal Pagi (07:45)
      var clockInTime = DateTime(now.year, now.month, now.day, 7, 45);
      if (clockInTime.isBefore(now)) {
        clockInTime = clockInTime.add(const Duration(days: 1));
      }

      await _schedule(
        id: 101,
        title: 'Waktunya Absen Masuk! ☀️',
        body: 'Jangan lupa scan QR Code sebelum jam 08:00 ya.',
        scheduledTime: clockInTime,
      );

      // Jadwal Sore (16:50)
      var clockOutTime = DateTime(now.year, now.month, now.day, 16, 50);
      if (clockOutTime.isBefore(now)) {
        clockOutTime = clockOutTime.add(const Duration(days: 1));
      }

      await _schedule(
        id: 102,
        title: 'Sudah Waktunya Pulang! 🏠',
        body:
            'Kerja bagus hari ini! Jangan lupa absen pulang sebelum meninggalkan kantor.',
        scheduledTime: clockOutTime,
      );

      // print("✅ Daily reminders scheduled");
    } catch (e) {
      // print("❌ Failed to schedule daily reminders: $e");
    }
  }

  // Helper Private untuk Schedule
  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Daily Reminders',
          channelDescription: 'Pengingat harian rutin',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
