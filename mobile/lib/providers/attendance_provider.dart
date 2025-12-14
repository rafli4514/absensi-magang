import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/attendance_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/indonesian_time.dart';

class AttendanceProvider with ChangeNotifier {
  String _clockInTime = '--:--';
  String? _clockOutTime;
  bool _isClockedIn = false;
  bool _isClockedOut = false;
  DateTime? _lastClockIn;

  // Untuk waktu real-time
  late Timer _timeUpdateTimer;
  String _currentTime = '';
  String _currentDate = '';

  // Getters
  String get clockInTime => _clockInTime;
  String? get clockOutTime => _clockOutTime;
  bool get isClockedIn => _isClockedIn;
  bool get isClockedOut => _isClockedOut;
  DateTime? get lastClockIn => _lastClockIn;
  String get currentTime => _currentTime;
  String get currentDate => _currentDate;

  AttendanceProvider() {
    _updateCurrentTime();
    // Setup timer untuk update waktu setiap menit
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCurrentTime();
    });
    // Load today's attendance status from API
    _loadTodayAttendance();
  }

  /// Load today's attendance status from API
  Future<void> _loadTodayAttendance() async {
    try {
      // Get pesertaMagangId
      String? pesertaMagangId;
      try {
        final userDataStr = await StorageService.getString(AppConstants.userDataKey);
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr);
          pesertaMagangId = userData['pesertaMagang']?['id']?.toString();
        }
      } catch (e) {
        if (kDebugMode) print('Error getting pesertaMagangId: $e');
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        return;
      }

      // Get today's attendance
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await AttendanceService.getAllAttendance(
        pesertaMagangId: pesertaMagangId,
        limit: 100,
      );

      if (response.success && response.data != null) {
        final todayAttendances = response.data!.where((attendance) {
          final timestamp = attendance.timestamp;
          return timestamp.isAfter(startOfDay) && timestamp.isBefore(endOfDay);
        }).toList();

        // Find MASUK and KELUAR
        DateTime? masukTime;
        DateTime? keluarTime;

        for (final attendance in todayAttendances) {
          if (attendance.tipe.toUpperCase() == 'MASUK' && masukTime == null) {
            masukTime = attendance.timestamp;
          } else if (attendance.tipe.toUpperCase() == 'KELUAR' && keluarTime == null) {
            keluarTime = attendance.timestamp;
          }
        }

        if (masukTime != null) {
          _clockInTime = IndonesianTime.formatTime(masukTime);
          _isClockedIn = true;
          _lastClockIn = masukTime;
        }

        if (keluarTime != null) {
          _clockOutTime = IndonesianTime.formatTime(keluarTime);
          _isClockedOut = true;
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading today attendance: $e');
    }
  }

  /// Refresh today's attendance status
  Future<void> refreshTodayAttendance() async {
    await _loadTodayAttendance();
  }

  void _updateCurrentTime() {
    _currentTime = IndonesianTime.formatTime(IndonesianTime.now);
    _currentDate = IndonesianTime.getFormattedDate();
    notifyListeners();
  }

  @override
  void dispose() {
    _timeUpdateTimer.cancel();
    super.dispose();
  }

  // Methods
  void clockIn(String time) {
    if (kDebugMode) {
      print('🟢 PROVIDER: Clock In called with time: $time');
      print(
        '🟢 PROVIDER: Before - isClockedIn: $_isClockedIn, clockInTime: $_clockInTime',
      );
    }

    _clockInTime = time;
    _isClockedIn = true;
    _isClockedOut = false;
    _lastClockIn = DateTime.now();

    if (kDebugMode) {
      print(
        '🟢 PROVIDER: After - isClockedIn: $_isClockedIn, clockInTime: $_clockInTime',
      );
    }

    notifyListeners();
    if (kDebugMode) {
      print('🟢 PROVIDER: notifyListeners() called');
    }
  }

  void clockOut(String time) {
    if (kDebugMode) {
      print('🔴 PROVIDER: Clock Out called with time: $time');
    }

    _clockOutTime = time;
    _isClockedOut = true;
    notifyListeners();
  }

  void resetAttendance() {
    _clockInTime = '--:--';
    _clockOutTime = null;
    _isClockedIn = false;
    _isClockedOut = false;
    _lastClockIn = null;
    notifyListeners();
  }

  // Validasi waktu - menggunakan waktu real-time
  bool get canClockIn {
    final now = IndonesianTime.now;
    return now.hour >= 8;
  }

  bool get canClockOut {
    if (!_isClockedIn || _isClockedOut) return false;
    final now = IndonesianTime.now;
    return now.hour >= 17;
  }

  // Get current greeting
  String get currentGreeting {
    return IndonesianTime.getGreeting();
  }
}
