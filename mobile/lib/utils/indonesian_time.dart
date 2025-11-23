import 'package:intl/intl.dart';

class IndonesianTime {
  // Timezone untuk WIB (Western Indonesian Time) - UTC+7
  static const int timeZoneOffset = 7;

  // Get current time in Indonesia timezone
  static DateTime get now {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: timeZoneOffset));
  }

  // Format date to Indonesian format: "Rabu, 8 Oktober 2025"
  static String getFormattedDate() {
    final indonesianNow = now;
    final dayName = _getDayName(indonesianNow.weekday);
    final monthName = _getMonthName(indonesianNow.month);
    return '$dayName, ${indonesianNow.day} $monthName ${indonesianNow.year}';
  }

  // Format time: "14.16"
  static String getFormattedTime() {
    final indonesianNow = now;
    return '${indonesianNow.hour.toString().padLeft(2, '0')}.${indonesianNow.minute.toString().padLeft(2, '0')}';
  }

  // Format date for display: "Rabu • 8 Oktober 2025"
  static String getFormattedDateWithSeparator() {
    final indonesianNow = now;
    final dayName = _getDayName(indonesianNow.weekday);
    final monthName = _getMonthName(indonesianNow.month);
    return '$dayName • ${indonesianNow.day} $monthName ${indonesianNow.year}';
  }

  // Format date only: "8 Oktober 2025"
  static String getFormattedDateOnly() {
    final indonesianNow = now;
    final monthName = _getMonthName(indonesianNow.month);
    return '${indonesianNow.day} $monthName ${indonesianNow.year}';
  }

  // Format day and date: "Rabu • 8 Oktober 2025"
  static String getDayAndDate() {
    final indonesianNow = now;
    final dayName = _getDayName(indonesianNow.weekday);
    final monthName = _getMonthName(indonesianNow.month);
    return '$dayName • ${indonesianNow.day} $monthName ${indonesianNow.year}';
  }

  // Format for database/API: "2025-10-08"
  static String getFormattedDateForAPI() {
    final indonesianNow = now;
    return DateFormat('yyyy-MM-dd').format(indonesianNow);
  }

  // Format for time with seconds: "14.16.30"
  static String getFormattedTimeWithSeconds() {
    final indonesianNow = now;
    return '${indonesianNow.hour.toString().padLeft(2, '0')}.${indonesianNow.minute.toString().padLeft(2, '0')}.${indonesianNow.second.toString().padLeft(2, '0')}';
  }

  // Helper function to get day name in Indonesian
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  // Helper function to get month name in Indonesian
  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  // Check if current time is working hours (8 AM - 5 PM)
  static bool get isWorkingHours {
    final indonesianNow = now;
    return indonesianNow.hour >= 8 && indonesianNow.hour < 17;
  }

  // Check if current day is weekday
  static bool get isWeekday {
    final indonesianNow = now;
    return indonesianNow.weekday >= 1 && indonesianNow.weekday <= 5;
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final indonesianNow = now;
    final hour = indonesianNow.hour;

    if (hour >= 5 && hour < 12) {
      return 'Selamat pagi';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat siang';
    } else if (hour >= 15 && hour < 19) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }
}
