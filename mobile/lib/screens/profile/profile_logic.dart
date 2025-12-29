import 'package:intl/intl.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class ProfileLogic {
  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // Parse dan format tanggal dari user data
  static ({
    String joinDate,
    String? endDate,
    DateTime? startDate,
    DateTime? endDateTime,
    int remainingDays,
    String displayStartDate,
    String displayEndDate,
    bool hasValidInternshipDates,
  }) parseUserDates(User? user) {
    String joinDate = '-';
    String? endDate;
    DateTime? startDate;
    DateTime? endDateTime;
    int remainingDays = 0;
    String displayStartDate = '-';
    String displayEndDate = '-';
    bool hasValidInternshipDates = false;

    if (user?.createdAt != null) {
      joinDate = DateFormat('dd MMM yyyy').format(user!.createdAt!);
    }

    if (user?.tanggalMulai != null) {
      startDate = DateTime.tryParse(user!.tanggalMulai!);
      if (startDate != null) {
        displayStartDate = DateFormat('dd MMM yyyy').format(startDate);
      }
    }

    if (user?.tanggalSelesai != null) {
      endDateTime = DateTime.tryParse(user!.tanggalSelesai!);
      if (endDateTime != null) {
        endDate = DateFormat('dd MMM yyyy').format(endDateTime);
        displayEndDate = endDate;

        final now = DateTime.now();
        final dateNow = DateTime(now.year, now.month, now.day);
        final dateEnd = DateTime(
          endDateTime.year,
          endDateTime.month,
          endDateTime.day,
        );

        remainingDays = dateEnd.difference(dateNow).inDays;
        if (remainingDays < 0) remainingDays = 0;
      }
    }

    hasValidInternshipDates = startDate != null && endDateTime != null;

    return (
      joinDate: joinDate,
      endDate: endDate,
      startDate: startDate,
      endDateTime: endDateTime,
      remainingDays: remainingDays,
      displayStartDate: displayStartDate,
      displayEndDate: displayEndDate,
      hasValidInternshipDates: hasValidInternshipDates,
    );
  }

  // Extract data yang sering digunakan (termasuk MENTOR)
  static ({
    String displayDivisi,
    String displayInstansi,
    String mentorName, // Field ini wajib didefinisikan di sini
    bool isStudent
  }) extractUserData(User? user, AuthProvider authProvider) {
    return (
      displayDivisi: user?.divisi ?? '-',
      displayInstansi: user?.instansi ?? '-',
      mentorName: user?.namaMentor ?? '-', // Extract dari user
      isStudent: authProvider.isStudent,
    );
  }
}
