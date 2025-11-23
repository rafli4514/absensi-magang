import 'package:flutter/foundation.dart';

class AttendanceProvider with ChangeNotifier {
  String _clockInTime = '--:--';
  String? _clockOutTime;
  bool _isClockedIn = false;
  bool _isClockedOut = false;
  DateTime? _lastClockIn;

  // Getters
  String get clockInTime => _clockInTime;
  String? get clockOutTime => _clockOutTime;
  bool get isClockedIn => _isClockedIn;
  bool get isClockedOut => _isClockedOut;
  DateTime? get lastClockIn => _lastClockIn;

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

  // Validasi waktu
  bool get canClockIn {
    final now = DateTime.now();
    return now.hour >= 8;
  }

  bool get canClockOut {
    if (!_isClockedIn || _isClockedOut) return false;
    final now = DateTime.now();
    return now.hour >= 17;
  }
}
