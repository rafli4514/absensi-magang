import 'dart:async';

class LiveTimeService {
  static final LiveTimeService _instance = LiveTimeService._internal();
  factory LiveTimeService() => _instance;
  LiveTimeService._internal();

  final StreamController<DateTime> _timeController =
      StreamController<DateTime>.broadcast();
  Timer? _timer;

  Stream<DateTime> get currentTimeStream => _timeController.stream;

  void start() {
    if (_timer != null && _timer!.isActive) return;

    // Update setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeController.add(DateTime.now());
    });

    // Initial value
    _timeController.add(DateTime.now());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _timeController.close();
  }

  // Format time helper
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Format dengan detik jika diperlukan
  static String formatTimeWithSeconds(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
