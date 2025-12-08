// lib/utils/validators.dart

enum PasswordStrength {
  weak(1),
  medium(2),
  strong(3),
  veryStrong(4);

  const PasswordStrength(this.value);
  final int value;
}

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s.'-]+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Please enter a valid name';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleanedPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Please enter a valid Indonesian phone number';
    }

    return null;
  }

  // --- PERBAIKAN DI SINI ---
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal harus diisi';
    }

    // Regex diubah untuk menerima format YYYY-MM-DD
    // \d{4} = Tahun (4 digit)
    // \d{1,2} = Bulan/Hari (1 atau 2 digit)
    final dateRegex = RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$');

    if (!dateRegex.hasMatch(value)) {
      // Kita toleransi error message, tapi logicnya sekarang terima YYYY-MM-DD
      return 'Format tanggal tidak valid (gunakan Date Picker)';
    }

    try {
      final parts = value.split(RegExp(r'[/-]'));

      // PERBAIKAN PARSING:
      // Format YYYY-MM-DD -> Index 0: Tahun, 1: Bulan, 2: Hari
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Validasi Bulan
      if (month < 1 || month > 12) {
        return 'Bulan harus antara 1-12';
      }

      // Validasi Hari Dasar
      if (day < 1 || day > 31) {
        return 'Hari harus antara 1-31';
      }

      // Validasi Jumlah Hari per Bulan
      if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
        return 'Bulan ini hanya memiliki 30 hari';
      }

      // Validasi Februari (Kabisat)
      if (month == 2) {
        final isLeapYear =
            (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        if (day > (isLeapYear ? 29 : 28)) {
          return 'Februari tahun $year hanya memiliki ${isLeapYear ? 29 : 28} hari';
        }
      }

      return null;
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 50) {
      return 'Password must be less than 50 characters';
    }

    return null;
  }

  static PasswordStrength getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    if (password.contains(RegExp(r'[a-zA-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    if (strength <= 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  static String getPasswordHint() {
    return 'Use at least 8 characters';
  }

  static String getUsernameHint() {
    return '3-20 characters\nLetters, numbers, and underscores only\nNo spaces or special characters';
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
