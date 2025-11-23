import 'dart:ui';

class OnboardModel {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}

class OnboardData {
  static final List<OnboardModel> pages = [
    OnboardModel(
      title: "Welcome to Employee App",
      description:
          "Manage your attendance and activities efficiently with our easy-to-use mobile application",
      imagePath: "assets/images/onboard1.png",
      backgroundColor: const Color(0xFFE3F2FD),
    ),
    OnboardModel(
      title: "QR Code Attendance",
      description:
          "Scan QR codes to record your attendance quickly and accurately. No more manual time tracking!",
      imagePath: "assets/images/onboard2.png",
      backgroundColor: const Color(0xFFE8F5E8),
    ),
    OnboardModel(
      title: "Track Your Performance",
      description:
          "Monitor your activities, attendance history, and performance metrics in real-time. Stay informed about your progress!",
      imagePath: "assets/images/onboard3.png",
      backgroundColor: const Color(0xFFFFF3E0),
    ),
  ];
}
