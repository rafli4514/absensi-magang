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
  List<String> _workDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday'
  ];
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
  Future<void> _loadTodayAttendance({bool preserveLocalState = false}) async {
    try {
      // Get pesertaMagangId (Logic pengambilan ID yang sudah diperbaiki sebelumnya)
      String? pesertaMagangId;
      try {
        final userDataStr =
            await StorageService.getString(AppConstants.userDataKey);
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr);
          // Cek berbagai kemungkinan key ID
          if (userData['pesertaMagang'] != null &&
              userData['pesertaMagang']['id'] != null) {
            pesertaMagangId = userData['pesertaMagang']['id'].toString();
          } else if (userData['idPesertaMagang'] != null) {
            pesertaMagangId = userData['idPesertaMagang'].toString();
          } else if (userData['pesertaMagangId'] != null) {
            pesertaMagangId = userData['pesertaMagangId'].toString();
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error getting pesertaMagangId: $e');
      }

      if (pesertaMagangId == null || pesertaMagangId.isEmpty) {
        return;
      }

      // Deteksi pergantian akun
      final bool userChanged = _currentPesertaMagangId != null &&
          _currentPesertaMagangId != pesertaMagangId;
      _currentPesertaMagangId = pesertaMagangId;

      final bool effectivePreserveLocalState =
          preserveLocalState && !userChanged;

      // Reset state jika user baru
      if (userChanged) {
        _clockInTime = '--:--';
        _clockOutTime = null;
        _isClockedIn = false;
        _isClockedOut = false;
        _lastClockIn = null;
        notifyListeners();
      }

      // --- LOGIKA TANGGAL YANG DIPERBAIKI (HAPUS OFFSET 7 JAM) ---
      // Karena data di DB sudah WIB (09:27), kita bandingkan langsung.
      final nowWib = IndonesianTime.now;

      final response = await AttendanceService.getAllAttendance(
        pesertaMagangId: pesertaMagangId,
        limit: 100,
      );

      if (response.success && response.data != null) {
        // Filter record hari ini
        final todayAttendances = response.data!.where((attendance) {
          // PERBAIKAN DI SINI: Jangan tambah 7 jam lagi.
          // Anggap timestamp dari API sudah merepresentasikan waktu lokal yang benar.
          // Kita gunakan .toLocal() atau langsung fieldnya jika timezone aware,
          // tapi agar aman kita ambil komponen waktu raw-nya.

          final recordDate = attendance.timestamp;

          // Bandingkan Tahun, Bulan, Tanggal secara langsung
          return recordDate.year == nowWib.year &&
              recordDate.month == nowWib.month &&
              recordDate.day == nowWib.day;
        }).toList();

        if (kDebugMode) {
          print(
              '📥 PROVIDER: Found ${todayAttendances.length} records matching today');
        }

        DateTime? masukTime;
        DateTime? keluarTime;

        final sortedAttendances = todayAttendances.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        for (final attendance in sortedAttendances) {
          final tipe = attendance.tipe.toUpperCase();
          if (tipe == 'MASUK' && masukTime == null) {
            masukTime = attendance.timestamp;
          } else if (tipe == 'KELUAR' && keluarTime == null) {
            keluarTime = attendance.timestamp;
          }
        }

        // --- UPDATE STATE UI (HAPUS OFFSET 7 JAM) ---

        // 1. Set Data Masuk
        if (masukTime != null) {
          // PERBAIKAN: Gunakan formatTime langsung dari object datetime yang didapat
          // Tanpa .add(Duration(hours: 7))
          _clockInTime = IndonesianTime.formatTime(masukTime);
          _isClockedIn = true;
          _lastClockIn = masukTime;
        } else if (!effectivePreserveLocalState) {
          _clockInTime = '--:--';
          _isClockedIn = false;
          _lastClockIn = null;
        }

        // 2. Set Data Keluar
        if (keluarTime != null) {
          // PERBAIKAN: Gunakan formatTime langsung
          _clockOutTime = IndonesianTime.formatTime(keluarTime);
          _isClockedOut = true;

          if (!_isClockedIn) {
            _isClockedIn = true;
          }
        } else if (!effectivePreserveLocalState) {
          _clockOutTime = null;
          _isClockedOut = false;
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading today attendance: $e');
    }
  }

  Future<void> refreshTodayAttendance({bool preserveLocalState = false}) async {
    await _loadTodayAttendance(preserveLocalState: preserveLocalState);
  }

  void _updateCurrentTime({bool initial = false}) {
    final now = IndonesianTime.now;
    final newTime = IndonesianTime.formatTime(now);
    final newDate = IndonesianTime.getFormattedDate();
    final newDateKey = '${now.year}-${now.month}-${now.day}';

    final isNewDay =
        !initial && _lastDateKey.isNotEmpty && newDateKey != _lastDateKey;

    _currentTime = newTime;
    _currentDate = newDate;
    _lastDateKey = newDateKey;

    if (isNewDay) {
      if (kDebugMode)
        print('📅 PROVIDER: New day detected. Resetting attendance.');
      _clockInTime = '--:--';
      _clockOutTime = null;
      _isClockedIn = false;
      _isClockedOut = false;
      _lastClockIn = null;
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

        _workStartTime = (schedule['workStartTime'] as String?) ?? '08:00';
        _workEndTime = (schedule['workEndTime'] as String?) ?? '17:00';

        if (schedule['workDays'] is List) {
          _workDays = List<String>.from(schedule['workDays'] as List);
        }

        _settingsLoaded = true;
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

  // Methods UI update realtime
  void clockIn(String time) {
    _clockInTime = time;
    _isClockedIn = true;
    _isClockedOut = false;
    _lastClockIn = IndonesianTime.now;
    notifyListeners();
  }

  void clockOut(String time) {
    _clockOutTime = time;
    _isClockedOut = true;
    if (!_isClockedIn) {
      _isClockedIn = true;
    }
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

  bool get canClockIn {
    final now = IndonesianTime.now;
    final dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final currentDay = dayNames[now.weekday - 1];

    if (!_workDays.contains(currentDay)) return false;

    final parts = _workStartTime.split(':');
    int startHour = 8;
    int startMinute = 0;
    if (parts.length == 2) {
      startHour = int.tryParse(parts[0]) ?? 8;
      startMinute = int.tryParse(parts[1]) ?? 0;
    }

    if (now.hour < startHour) return false;
    if (now.hour == startHour && now.minute < startMinute) return false;

    return true;
  }

  bool get canClockOut {
    if (!_isClockedIn || _isClockedOut) return false;
    return true;
  }

  String get currentGreeting {
    return IndonesianTime.getGreeting();
  }
}
