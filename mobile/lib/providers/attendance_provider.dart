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

      // Get today's attendance (using Indonesian time)
      final today = IndonesianTime.now;
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await AttendanceService.getAllAttendance(
        pesertaMagangId: pesertaMagangId,
        limit: 100,
      );

      if (response.success && response.data != null) {
        final todayAttendances = response.data!.where((attendance) {
          final timestamp = attendance.timestamp;
          // Ensure timestamp is a DateTime
          if (timestamp is DateTime) {
            return timestamp.isAfter(startOfDay) && timestamp.isBefore(endOfDay);
          } else {
            // If timestamp is a string, parse it first
            try {
              final parsedTimestamp = DateTime.parse(timestamp.toString());
              return parsedTimestamp.isAfter(startOfDay) && parsedTimestamp.isBefore(endOfDay);
            } catch (e) {
              if (kDebugMode) print('Error parsing timestamp: $e');
              return false;
            }
          }
        }).toList();
        
        if (kDebugMode) {
          print('📥 PROVIDER: Found ${todayAttendances.length} attendance records for today');
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
        } else if (!preserveLocalState) {
          // Only reset if not preserving local state and no record found
          // This preserves the local state set by clockIn() if API doesn't have it yet
        } else {
          if (kDebugMode) {
            print('📥 PROVIDER: No clock in found in API, preserving local state (preserveLocalState: $preserveLocalState)');
          }
        }

        if (keluarTime != null) {
          _clockOutTime = IndonesianTime.formatTime(keluarTime);
          _isClockedOut = true;
        } else if (!preserveLocalState) {
          // Only reset if not preserving local state
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