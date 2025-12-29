import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _idPesertaMagangController = TextEditingController();
  final _divisiController = TextEditingController();
  final _instansiController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  PasswordStrength _passwordStrength = PasswordStrength.weak;
  bool _acceptedTerms = false;
  bool _showUsernameHint = false;

  // --- OPSI DIVISI DENGAN ICON (Updated) ---
  final List<Map<String, dynamic>> _divisiOptions = [
    {
      "label": "Bidang Pemasaran & Penjualan",
      "icon": Icons.campaign_rounded,
    },
    {
      "label": "Retail SBU",
      "icon": Icons.storefront_rounded,
    },
    {
      "label": "Pembangunan & Aktivasi",
      "icon": Icons.construction_rounded,
    },
    {
      "label": "Operasi Pemeliharaan & Aset",
      "icon": Icons.engineering_rounded,
    },
  ];

  String? _selectedDivisi;

  int _selectedDuration = 3;
  final List<int> _durations = [1, 2, 3, 4, 5, 6, 12];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _idPesertaMagangController.dispose();
    _divisiController.dispose();
    _instansiController.dispose();
    _nomorHpController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _passwordStrength =
            Validators.getPasswordStrength(_passwordController.text);
      });
    });
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(password);
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? AppThemes.darkTheme : AppThemes.lightTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalMulaiController.text = _dateFormat.format(picked);
        _calculateEndDate();
      });
    }
  }

  void _calculateEndDate() {
    if (_tanggalMulaiController.text.isNotEmpty) {
      try {
        final startDate = _dateFormat.parse(_tanggalMulaiController.text);
        final endDate = DateTime(
            startDate.year, startDate.month + _selectedDuration, startDate.day);
        _tanggalSelesaiController.text = _dateFormat.format(endDate);
      } catch (e) {
        _tanggalSelesaiController.text = '';
      }
    }
  }

  void _updateDuration(int duration) {
    setState(() => _selectedDuration = duration);
    _calculateEndDate();
  }

  Future<void> _register() async {
    if (!_acceptedTerms) {
      GlobalSnackBar.show('Harap setujui Syarat & Ketentuan', isWarning: true);
      return;
    }

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        nama: _namaController.text.trim(),
        idPesertaMagang: _idPesertaMagangController.text.trim(),
        divisi: _divisiController.text.trim(),
        instansi: _instansiController.text.trim(),
        nomorHp: _nomorHpController.text.trim(),
        tanggalMulai: _tanggalMulaiController.text.trim(),
        tanggalSelesai: _tanggalSelesaiController.text.trim(),
        role: 'peserta_magang',
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      } else if (!success && mounted) {
        GlobalSnackBar.show(authProvider.error ?? 'Registrasi gagal',
            isError: true);
        authProvider.clearError();
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Harap konfirmasi password';
    if (value != _passwordController.text) return 'Password tidak cocok';
    return null;
  }

  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return AppThemes.errorColor;
      case PasswordStrength.medium:
        return AppThemes.warningColor;
      case PasswordStrength.strong:
        return AppThemes.successColor;
      case PasswordStrength.veryStrong:
        return AppThemes.successDark;
    }
  }

  String _getPasswordStrengthText() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return 'Lemah';
      case PasswordStrength.medium:
        return 'Cukup';
      case PasswordStrength.strong:
        return 'Baik';
      case PasswordStrength.veryStrong:
        return 'Kuat';
    }
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppThemes.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color:
                    isDark ? AppThemes.darkTextTertiary : AppThemes.hintColor,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDurationSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durasi Magang',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color:
                isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _durations.map((duration) {
              final isSelected = _selectedDuration == duration;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _updateDuration(duration),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppThemes.primaryColor
                          : (isDark
                              ? AppThemes.darkSurface
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppThemes.primaryColor
                            : (isDark
                                ? AppThemes.darkOutline
                                : Colors.grey.shade300),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$duration Bulan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppThemes.darkTextPrimary
                                : AppThemes.primaryColor),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Akun Baru',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data diri untuk memulai',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader('Informasi Pribadi',
                    subtitle: 'Data diri lengkap Anda'),

                // 1. Nama Lengkap
                CustomTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Nama lengkap sesuai KTP',
                  icon: Icons.person_rounded,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                // 2. NIM / NISN
                CustomTextField(
                  controller: _idPesertaMagangController,
                  label: 'NIM / NISN',
                  hint: 'Masukkan NIM / NISN',
                  icon: Icons.badge_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // 3. Username
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Username unik',
                  icon: Icons.alternate_email_rounded,
                  validator: Validators.validateUsername,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showUsernameHint ? Icons.info : Icons.info_outline,
                        size: 20,
                        color: AppThemes.primaryColor),
                    onPressed: () =>
                        setState(() => _showUsernameHint = !_showUsernameHint),
                  ),
                ),
                if (_showUsernameHint)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(Validators.getUsernameHint(),
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppThemes.darkTextTertiary
                                : AppThemes.hintColor)),
                  ),
                const SizedBox(height: 16),

                // 4. Nomor HP
                CustomTextField(
                  controller: _nomorHpController,
                  label: 'Nomor HP',
                  hint: 'Contoh: 08123456789',
                  icon: Icons.phone_rounded,
                  validator: Validators.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Informasi Magang',
                    subtitle: 'Detail penempatan Anda'),

                // 5. Divisi (DROPDOWN REFINED & ELEGANT)
                DropdownButtonFormField<String>(
                  value: _selectedDivisi,
                  // Ikon panah minimalis
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor,
                    size: 20,
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                    fontWeight: FontWeight.w500,
                  ),
                  itemHeight: kMinInteractiveDimension, // Standar 48px
                  isExpanded: true,
                  dropdownColor:
                      isDark ? AppThemes.darkSurfaceElevated : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  // Logic item builder
                  items: _divisiOptions.map((Map<String, dynamic> item) {
                    final isSelected = _selectedDivisi == item['label'];
                    // Warna dinamis untuk selected state
                    final iconColor = isSelected
                        ? (isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor)
                        : (isDark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.hintColor);
                    final textColor = isSelected
                        ? (isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor)
                        : (isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor);

                    return DropdownMenuItem<String>(
                      value: item['label'],
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            size: 18,
                            color: iconColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Indikator centang jika dipilih
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: iconColor,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDivisi = newValue;
                      _divisiController.text = newValue ?? '';
                    });
                  },
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Wajib dipilih' : null,
                  // Dekorasi yang konsisten dengan CustomTextField tapi lebih compact
                  decoration: InputDecoration(
                    labelText: 'Divisi',
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : AppThemes.hintColor,
                    ),
                    hintText: 'Pilih Divisi Penempatan',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppThemes.darkTextTertiary
                          : AppThemes.hintColor.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: isDark ? AppThemes.darkSurface : Colors.white,
                    prefixIcon: Icon(Icons.work_outline_rounded,
                        color: AppThemes.primaryColor, size: 18),
                    // Border konsisten
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppThemes.primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppThemes.errorColor, width: 1.5),
                    ),
                    // KUNCI: Padding yang pas agar tidak kopong
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Instansi
                CustomTextField(
                  controller: _instansiController,
                  label: 'Instansi / Kampus',
                  hint: 'Asal Universitas/Sekolah',
                  icon: Icons.school_rounded,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // 7. Tanggal Mulai
                CustomTextField(
                  controller: _tanggalMulaiController,
                  label: 'Tanggal Mulai',
                  hint: 'Pilih tanggal',
                  icon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _selectStartDate,
                  validator: Validators.validateDate,
                ),
                const SizedBox(height: 16),

                // 8. Pilihan Durasi
                _buildDurationSelection(),
                const SizedBox(height: 16),

                // 9. Tanggal Selesai (Auto)
                CustomTextField(
                  controller: _tanggalSelesaiController,
                  label: 'Tanggal Selesai',
                  hint: 'Terisi otomatis',
                  icon: Icons.event_available_rounded,
                  readOnly: true,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Keamanan', subtitle: 'Lindungi akun Anda'),

                // 10. Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Minimal 8 karakter',
                  icon: Icons.lock_outline_rounded,
                  validator: Validators.validatePassword,
                  isPassword: true,
                ),
                // Password Strength indicator
                if (_passwordController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _passwordStrength.value / 4,
                            backgroundColor: isDark
                                ? AppThemes.darkOutline
                                : Colors.grey.shade300,
                            color: _getPasswordStrengthColor(),
                            borderRadius: BorderRadius.circular(2),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getPasswordStrengthText(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getPasswordStrengthColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // 11. Konfirmasi Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  icon: Icons.lock_reset_outlined,
                  validator: _validateConfirmPassword,
                  isPassword: true,
                ),

                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                        activeColor: AppThemes.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi yang berlaku.',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: authProvider.isLoading
                      ? const Center(child: LoadingIndicator())
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _acceptedTerms
                                ? AppThemes.primaryColor
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Buat Akun',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah punya akun? ",
                        style: TextStyle(
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, RouteNames.login),
                      child: Text("Masuk",
                          style: TextStyle(
                              color: AppThemes.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
