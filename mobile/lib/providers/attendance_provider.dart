import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/attendance_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/indonesian_time.dart';

class AttendanceProvider with ChangeNotifier {
  String _clockInTime = '--:--';
  String? _clockOutTime;
  bool _isClockedIn = false;
  bool _isClockedOut = false;
  DateTime? _lastClockIn;
  String? _currentPesertaMagangId;

  // Untuk waktu real-time
  late Timer _timeUpdateTimer;
  String _currentTime = '';
  String _currentDate = '';
  String _lastDateKey = '';

  // Settings dari backend (schedule & attendance)
  String _workStartTime = '08:00';
  String _workEndTime = '17:00';
  List<String> _workDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  bool _settingsLoaded = false;

  // Getters
  String get clockInTime => _clockInTime;
  String? get clockOutTime => _clockOutTime;
  bool get isClockedIn => _isClockedIn;
  bool get isClockedOut => _isClockedOut;
  DateTime? get lastClockIn => _lastClockIn;
  String get currentTime => _currentTime;
  String get currentDate => _currentDate;
  String get workStartTime => _workStartTime;
  String get workEndTime => _workEndTime;
  List<String> get workDays => _workDays;
  bool get settingsLoaded => _settingsLoaded;

  AttendanceProvider() {
    _updateCurrentTime(initial: true);
    // Setup timer untuk update waktu setiap menit
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCurrentTime();
    });
    // Load pengaturan absensi dari backend
    _loadAttendanceSettings();
    // Load today's attendance status from API
    _loadTodayAttendance();
  }

  /// Load today's attendance status from API
  /// [preserveLocalState] - if true, only update state if API has records, don't reset if empty
  Future<void> _loadTodayAttendance({bool preserveLocalState = false}) async {
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

      // Deteksi pergantian akun (pesertaMagangId berbeda dari sebelumnya)
      final bool userChanged =
          _currentPesertaMagangId != null && _currentPesertaMagangId != pesertaMagangId;
      _currentPesertaMagangId = pesertaMagangId;

      // Jika user berganti, kita TIDAK ingin preserve state lokal user lama
      final bool effectivePreserveLocalState =
          preserveLocalState && !userChanged;

      if (kDebugMode) {
        print(
            '📥 PROVIDER: Loading today attendance for pesertaMagangId=$pesertaMagangId, userChanged=$userChanged, preserveLocalState=$preserveLocalState, effectivePreserve=$effectivePreserveLocalState');
      }

      // Jika user baru, reset dulu state lokal agar tidak bocor dari akun sebelumnya
      if (userChanged) {
        _clockInTime = '--:--';
        _clockOutTime = null;
        _isClockedIn = false;
        _isClockedOut = false;
        _lastClockIn = null;
      }

      // Get today's attendance (gunakan tanggal Indonesia, bandingkan berdasarkan YYYY-MM-DD saja)
      final todayLocal = IndonesianTime.now;
      final todayDateOnly = DateTime(todayLocal.year, todayLocal.month, todayLocal.day);

      final response = await AttendanceService.getAllAttendance(
        pesertaMagangId: pesertaMagangId,
        limit: 100,
      );

      if (response.success && response.data != null) {
        final todayAttendances = response.data!.where((attendance) {
          // timestamp di model sudah disimpan dengan pola yang sama seperti IndonesianTime.now
          // jadi cukup bandingkan komponen tanggalnya (tahun, bulan, hari) tanpa offset tambahan.
          final ts = attendance.timestamp;
          final tsDateOnly = DateTime(ts.year, ts.month, ts.day);
          return tsDateOnly.year == todayDateOnly.year &&
              tsDateOnly.month == todayDateOnly.month &&
              tsDateOnly.day == todayDateOnly.day;
        }).toList();

        if (kDebugMode) {
          print('📥 PROVIDER: Today local date: $todayDateOnly');
          for (final att in response.data!) {
            final ts = att.timestamp;
            print('   ↪️ record: tipe=${att.tipe}, ts=$ts');
          }
          print(
              '📥 PROVIDER: Found ${todayAttendances.length} attendance records FOR TODAY (by date only)');
        }

        // Find MASUK and KELUAR (ambil yang terakhir untuk mendukung multiple clock in)
        DateTime? masukTime;
        DateTime? keluarTime;

        // Sort by timestamp descending to get the latest
        final sortedAttendances = todayAttendances.toList()
          ..sort((a, b) {
            final aTime = a.timestamp is DateTime ? a.timestamp as DateTime : DateTime.parse(a.timestamp.toString());
            final bTime = b.timestamp is DateTime ? b.timestamp as DateTime : DateTime.parse(b.timestamp.toString());
            return bTime.compareTo(aTime); // Descending
          });

        for (final attendance in sortedAttendances) {
          if (attendance.tipe.toUpperCase() == 'MASUK' && masukTime == null) {
            masukTime = attendance.timestamp is DateTime 
              ? attendance.timestamp as DateTime 
              : DateTime.parse(attendance.timestamp.toString());
          } else if (attendance.tipe.toUpperCase() == 'KELUAR' && keluarTime == null) {
            keluarTime = attendance.timestamp is DateTime 
              ? attendance.timestamp as DateTime 
              : DateTime.parse(attendance.timestamp.toString());
          }
        }

        // Only update if we found records, or if not preserving local state
        if (masukTime != null) {
          _clockInTime = IndonesianTime.formatTime(masukTime);
          _isClockedIn = true;
          _lastClockIn = masukTime;
          
          if (kDebugMode) {
            print('📥 PROVIDER: Updated clock in from API - time: $_clockInTime, isClockedIn: $_isClockedIn');
          }
        } else if (!effectivePreserveLocalState) {
          // Only reset if not preserving local state and no record found
          // Ini akan mereset state jika:
          // - User baru (userChanged == true), ATAU
          // - preserveLocalState == false
          _clockInTime = '--:--';
          _isClockedIn = false;
          _lastClockIn = null;
        } else {
          if (kDebugMode) {
            print(
                '📥 PROVIDER: No clock in found in API, preserving local state (effectivePreserve: $effectivePreserveLocalState)');
          }
        }

        if (keluarTime != null) {
          _clockOutTime = IndonesianTime.formatTime(keluarTime);
          _isClockedOut = true;
        } else if (!effectivePreserveLocalState) {
          // Only reset if not preserving local state
          _clockOutTime = null;
          _isClockedOut = false;
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading today attendance: $e');
    }
  }

  /// Refresh today's attendance status
  /// [preserveLocalState] - if true, preserve local state if API doesn't have records yet
  Future<void> refreshTodayAttendance({bool preserveLocalState = false}) async {
    await _loadTodayAttendance(preserveLocalState: preserveLocalState);
  }

  void _updateCurrentTime({bool initial = false}) {
    final now = IndonesianTime.now;
    final newTime = IndonesianTime.formatTime(now);
    final newDate = IndonesianTime.getFormattedDate();
    final newDateKey = '${now.year}-${now.month}-${now.day}';

    // Jika hari berganti (dibanding _lastDateKey) — reset status absensi & reload dari API
    final isNewDay = !initial && _lastDateKey.isNotEmpty && newDateKey != _lastDateKey;
    _currentTime = newTime;
    _currentDate = newDate;
    _lastDateKey = newDateKey;

    if (isNewDay) {
      // Reset state lokal untuk hari baru
      _clockInTime = '--:--';
      _clockOutTime = null;
      _isClockedIn = false;
      _isClockedOut = false;
      _lastClockIn = null;
      // Muat ulang absensi hari ini dari API (tanpa preserveLocalState)
      _loadTodayAttendance(preserveLocalState: false);
    }

    notifyListeners();
  }

  Future<void> _loadAttendanceSettings() async {
    try {
      final response = await SettingsService.getSettings();
      if (response.success && response.data != null) {
        final data = response.data!;
        final schedule = data['schedule'] ?? {};
        final attendance = data['attendance'] ?? {};

        _workStartTime = (schedule['workStartTime'] as String?) ?? '08:00';
        _workEndTime = (schedule['workEndTime'] as String?) ?? '17:00';

        if (schedule['workDays'] is List) {
          _workDays = List<String>.from(schedule['workDays'] as List);
        }

        _settingsLoaded = true;

        if (kDebugMode) {
          print('⚙️ PROVIDER: Settings loaded - workStart: $_workStartTime, workEnd: $_workEndTime, workDays: $_workDays');
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚙️ PROVIDER: Failed to load settings: $e');
      }
    }
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
    _lastClockIn = IndonesianTime.now; // Use Indonesian time

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
      print(
        '🔴 PROVIDER: Before - isClockedOut: $_isClockedOut, clockOutTime: $_clockOutTime',
      );
    }

    _clockOutTime = time;
    _isClockedOut = true;
    // Pastikan isClockedIn tetap true setelah check-out
    if (!_isClockedIn) {
      _isClockedIn = true;
    }

    if (kDebugMode) {
      print(
        '🔴 PROVIDER: After - isClockedIn: $_isClockedIn, isClockedOut: $_isClockedOut, clockOutTime: $_clockOutTime',
      );
    }

    notifyListeners();
    if (kDebugMode) {
      print('🔴 PROVIDER: notifyListeners() called');
    }
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

    // Konversi hari ke format pengaturan (monday, tuesday, ...)
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final currentDay = dayNames[now.weekday - 1];

    // Jika hari ini bukan hari kerja sesuai pengaturan, kembalikan false
    if (!_workDays.contains(currentDay)) {
      return false;
    }

    // Parse jam mulai kerja (HH:mm)
    final parts = _workStartTime.split(':');
    int startHour = 8;
    int startMinute = 0;
    if (parts.length == 2) {
      startHour = int.tryParse(parts[0]) ?? 8;
      startMinute = int.tryParse(parts[1]) ?? 0;
    }

    // Hanya membatasi jam mulai kerja, sama seperti backend
    if (now.hour < startHour) {
      return false;
    }
    if (now.hour == startHour && now.minute < startMinute) {
      return false;
    }

    return true;
  }

  bool get canClockOut {
    // Clock out mengikuti backend: bisa kapan saja selama sudah clock in dan belum clock out
    if (!_isClockedIn || _isClockedOut) return false;
    return true;
  }

  // Get current greeting
  String get currentGreeting {
    return IndonesianTime.getGreeting();
  }
}