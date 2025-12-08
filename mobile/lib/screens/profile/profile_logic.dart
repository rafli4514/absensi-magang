// screens/profile/profile_logic.dart
import 'package:intl/intl.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';

// --- PROFILE LOGIC/HELPERS ---

class ProfileLogic {
  // Helper function untuk mendapatkan inisial nama
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
  })
  parseUserDates(User? user) {
    String joinDate = '-';
    String? endDate;
    DateTime? startDate;
    DateTime? endDateTime;
    int remainingDays = 0;
    String displayStartDate = '-';
    String displayEndDate = '-';
    bool hasValidInternshipDates = false;

    // Parse join date
    if (user?.createdAt != null) {
      joinDate = DateFormat('dd MMM yyyy').format(user!.createdAt!);
    }

    // Parse tanggal mulai
    if (user?.tanggalMulai != null) {
      startDate = DateTime.tryParse(user!.tanggalMulai!);
      if (startDate != null) {
        displayStartDate = DateFormat('dd MMM yyyy').format(startDate);
      }
    }

    // Parse tanggal selesai
    if (user?.tanggalSelesai != null) {
      endDateTime = DateTime.tryParse(user!.tanggalSelesai!);
      if (endDateTime != null) {
        endDate = DateFormat('dd MMM yyyy').format(endDateTime);
        displayEndDate = endDate!;

        // Hitung sisa hari
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

  // Extract data yang sering digunakan
  static ({String displayDivisi, String displayInstansi, bool isStudent})
  extractUserData(User? user, AuthProvider authProvider) {
    return (
      displayDivisi: user?.divisi ?? '-',
      displayInstansi: user?.instansi ?? '-',
      isStudent: authProvider.isStudent,
    );
  }
}
