// validators.dart
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

    // Check for valid name characters (letters, spaces, and some special characters)
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

    // Username should only contain letters, numbers, and underscores
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

    // Remove any non-digit characters
    final cleanedPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it's a valid Indonesian phone number format
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Please enter a valid Indonesian phone number';
    }

    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal harus diisi';
    }

    // Terima berbagai format: DD/MM/YYYY, DD-MM-YYYY, atau input date picker
    final dateRegex = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$');
    if (!dateRegex.hasMatch(value)) {
      return 'Format tanggal: DD/MM/YYYY atau DD-MM-YYYY';
    }

    try {
      final parts = value.split(RegExp(r'[/-]'));
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Basic date validation
      if (month < 1 || month > 12) {
        return 'Bulan harus antara 1-12';
      }

      if (day < 1 || day > 31) {
        return 'Hari harus antara 1-31';
      }

      // Check for specific month days
      if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
        return 'Bulan ini hanya memiliki 30 hari';
      }

      // February check
      if (month == 2) {
        final isLeapYear =
            (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        if (day > (isLeapYear ? 29 : 28)) {
          return 'Februari hanya memiliki ${isLeapYear ? 29 : 28} hari di tahun $year';
        }
      }

      // HAPUS VALIDASI "TIDAK BOLEH DI MASA LALU" - biar user bebas milih tanggal
      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
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

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety checks (optional, tanpa uppercase requirement)
    if (password.contains(RegExp(r'[a-zA-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    // Determine strength level
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
