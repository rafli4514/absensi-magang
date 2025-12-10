import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_widget.dart';
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

  int _selectedDuration = 3;
  final List<int> _durations = [1, 2, 3, 4, 5, 6, 12];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
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
    // Hanya mendengarkan password untuk update strength bar secara lokal
    // Tidak memvalidasi form keseluruhan
    _passwordController.addListener(() {
      setState(() {
        _passwordStrength =
            Validators.getPasswordStrength(_passwordController.text);
      });
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppThemes.primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
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
          startDate.year,
          startDate.month + _selectedDuration,
          startDate.day,
        );
        _tanggalSelesaiController.text = _dateFormat.format(endDate);
      } catch (e) {
        _tanggalSelesaiController.text = '';
      }
    }
  }

  void _updateDuration(int duration) {
    setState(() {
      _selectedDuration = duration;
    });
    _calculateEndDate();
  }

  Future<void> _register() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap setujui Syarat & Ketentuan'),
          backgroundColor: AppThemes.warningColor,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        nama: _namaController.text.trim(),
        divisi: _divisiController.text.trim(),
        instansi: _instansiController.text.trim(),
        nomorHp: _nomorHpController.text.trim(),
        tanggalMulai: _tanggalMulaiController.text.trim(),
        tanggalSelesai: _tanggalSelesaiController.text.trim(),
        role: 'peserta_magang',
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
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
              width: 3,
              height: 16,
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
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 11),
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
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDurationSelection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durasi Magang',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color:
                isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _durations.map((duration) {
              final isSelected = _selectedDuration == duration;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => _updateDuration(duration),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppThemes.primaryColor
                          : AppThemes.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppThemes.primaryColor
                            : AppThemes.primaryColor.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      '$duration ${duration == 1 ? 'Bulan' : 'Bulan'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppThemes.primaryColor,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Hero(
                tag: 'app_logo',
                child: Center(
                  child: Image.asset(
                    'assets/images/InternLogoExpand.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                'Buat Akun',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mulai perjalanan magang Anda bersama kami',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      'Informasi Pribadi',
                      subtitle: 'Data diri lengkap untuk profil Anda',
                    ),
                    CustomTextField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_rounded,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 12),

                    // Username dengan suffix info
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Buat username unik',
                      icon: Icons.alternate_email_rounded,
                      validator: Validators.validateUsername,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showUsernameHint
                              ? Icons.info_outlined
                              : Icons.info_outline,
                          color: AppThemes.primaryColor.withOpacity(0.7),
                          size: 18,
                        ),
                        onPressed: () => setState(
                            () => _showUsernameHint = !_showUsernameHint),
                      ),
                    ),
                    if (_showUsernameHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          Validators.getUsernameHint(),
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppThemes.darkTextTertiary
                                  : AppThemes.hintColor),
                        ),
                      ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _nomorHpController,
                      label: 'Nomor HP',
                      hint: 'Masukkan nomor handphone',
                      icon: Icons.phone_rounded,
                      validator: Validators.validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      'Informasi Institusi',
                      subtitle: 'Data magang dan institusi pendidikan',
                    ),
                    CustomTextField(
                      controller: _divisiController,
                      label: 'Divisi',
                      hint: 'Masukkan divisi magang',
                      icon: Icons.business_center_rounded,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Divisi harus diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _instansiController,
                      label: 'Instansi',
                      hint: 'Masukkan nama instansi/universitas',
                      icon: Icons.school_rounded,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Instansi harus diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _tanggalMulaiController,
                      label: 'Tanggal Mulai',
                      hint: 'Pilih tanggal mulai',
                      icon: Icons.calendar_today_rounded,
                      readOnly: true,
                      onTap: _selectStartDate,
                      validator: Validators.validateDate,
                    ),
                    const SizedBox(height: 12),
                    _buildDurationSelection(),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _tanggalSelesaiController,
                      label: 'Tanggal Selesai',
                      hint: 'Dihitung otomatis',
                      icon: Icons.event_available_rounded,
                      readOnly: true,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      'Keamanan Akun',
                      subtitle: 'Buat password yang kuat untuk akun Anda',
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Buat password',
                      icon: Icons.lock_outline_rounded,
                      validator: Validators.validatePassword,
                      isPassword: true,
                    ),
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
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Konfirmasi password',
                      icon: Icons.lock_reset_outlined,
                      validator: _validateConfirmPassword,
                      isPassword: true,
                    ),

                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) =>
                                setState(() => _acceptedTerms = value ?? false),
                            activeColor: AppThemes.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Saya setuju dengan Syarat & Ketentuan dan Kebijakan Privasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (authProvider.error != null) ...[
                      const SizedBox(height: 12),
                      CustomErrorWidget(
                        message: authProvider.error!,
                        onDismiss: () => authProvider.clearError(),
                      ),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_add_outlined,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Buat Akun',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('atau',
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppThemes.darkTextTertiary
                                : AppThemes.hintColor)),
                  ),
                  Expanded(
                    child: Divider(
                        color: isDark
                            ? AppThemes.darkOutline
                            : Colors.grey.shade300),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sudah punya akun?",
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor)),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RouteNames.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppThemes.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                    ),
                    child: Text('Masuk',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppThemes.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
