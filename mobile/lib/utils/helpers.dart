class Helpers {
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }
}