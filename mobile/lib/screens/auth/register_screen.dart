import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/validators.dart';
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonHovered = false;
  bool _isFormValid = false;
  PasswordStrength _passwordStrength = PasswordStrength.weak;
  bool _acceptedTerms = false;
  bool _showUsernameHint = false;

  // Duration variables
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
      _tanggalMulaiController.text = _dateFormat.format(picked);
      _calculateEndDate();
      _validateForm();
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
    _validateForm();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
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

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(password);
    });
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

  @override
  void initState() {
    super.initState();
    _namaController.addListener(_validateForm);
    _usernameController.addListener(_validateForm);
    _divisiController.addListener(_validateForm);
    _instansiController.addListener(_validateForm);
    _nomorHpController.addListener(_validateForm);
    _tanggalMulaiController.addListener(_validateForm);
    _tanggalSelesaiController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
    });
  }

  // Widget untuk section header - lebih compact
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
                color: isDark
                    ? AppThemes.darkTextTertiary
                    : AppThemes.hintColor,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  // Widget untuk field tanggal mulai - lebih compact
  Widget _buildStartDateField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Mulai Magang',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark
                ? AppThemes.darkTextPrimary
                : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: _tanggalMulaiController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Pilih tanggal mulai',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: Icon(
                Icons.calendar_today_rounded,
                color: AppThemes.primaryColor,
                size: 18,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppThemes.primaryColor,
                  size: 20,
                ),
                onPressed: _selectStartDate,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              isDense: true,
            ),
            validator: Validators.validateDate,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk duration selection - lebih compact
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
            color: isDark
                ? AppThemes.darkTextPrimary
                : AppThemes.onSurfaceColor,
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
                        color: isSelected
                            ? Colors.white
                            : AppThemes.primaryColor,
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

  // Widget untuk display tanggal selesai - lebih compact
  Widget _buildEndDateDisplay() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Selesai Magang',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark
                ? AppThemes.darkTextPrimary
                : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppThemes.primaryColor.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _tanggalSelesaiController.text.isNotEmpty
                      ? _tanggalSelesaiController.text
                      : 'Pilih tanggal mulai terlebih dahulu',
                  style: TextStyle(
                    fontSize: 13,
                    color: _tanggalSelesaiController.text.isNotEmpty
                        ? (isDark
                              ? AppThemes.darkTextPrimary
                              : AppThemes.onSurfaceColor)
                        : (isDark
                              ? AppThemes.darkTextTertiary
                              : AppThemes.hintColor),
                  ),
                ),
              ),
              if (_tanggalSelesaiController.text.isNotEmpty)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppThemes.successColor,
                  size: 18,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Form field yang lebih compact
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleObscure,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, color: AppThemes.primaryColor, size: 18),
        suffixIcon: isPassword && onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText!
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppThemes.primaryColor,
                  size: 18,
                ),
                onPressed: onToggleObscure,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 36),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemes.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      obscureText: obscureText ?? false,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  // Build personal information section - lebih compact
  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Informasi Pribadi',
          subtitle: 'Data diri lengkap untuk profil Anda',
        ),
        _buildFormField(
          controller: _namaController,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
          icon: Icons.person_rounded,
          validator: Validators.validateName,
        ),
        const SizedBox(height: 12),

        // Username Field dengan Hint yang lebih compact
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Buat username unik',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                  color: AppThemes.primaryColor,
                  size: 18,
                ),
                suffixIcon: Container(
                  width: 36, // Lebar tetap untuk icon info
                  child: IconButton(
                    icon: Icon(
                      _showUsernameHint
                          ? Icons.info_outlined
                          : Icons.info_outline,
                      color: AppThemes.primaryColor.withOpacity(0.7),
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _showUsernameHint = !_showUsernameHint;
                      });
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppThemes.darkOutline
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppThemes.darkOutline
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppThemes.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                isDense: true,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              validator: Validators.validateUsername,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onChanged: (value) {
                _validateForm();
              },
            ),

            // Username Hint yang lebih compact
            if (_showUsernameHint)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppThemes.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Syarat Username:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppThemes.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ...Validators.getUsernameHint()
                          .split('\n')
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: Text(
                                '• $line',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppThemes.darkTextTertiary
                                          : AppThemes.hintColor,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        _buildFormField(
          controller: _nomorHpController,
          label: 'Nomor HP',
          hint: 'Masukkan nomor handphone',
          icon: Icons.phone_rounded,
          validator: Validators.validatePhoneNumber,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // Build institutional information section - lebih compact
  Widget _buildInstitutionalSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Informasi Institusi',
          subtitle: 'Data magang dan institusi pendidikan',
        ),
        _buildFormField(
          controller: _divisiController,
          label: 'Divisi',
          hint: 'Masukkan divisi magang',
          icon: Icons.business_center_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Divisi harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        _buildFormField(
          controller: _instansiController,
          label: 'Instansi',
          hint: 'Masukkan nama instansi/universitas',
          icon: Icons.school_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Instansi harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Duration-based date selection
        _buildStartDateField(),
        const SizedBox(height: 12),

        _buildDurationSelection(),
        const SizedBox(height: 12),

        _buildEndDateDisplay(),
      ],
    );
  }

  // Build account security section - lebih compact
  Widget _buildAccountSecuritySection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Keamanan Akun',
          subtitle: 'Buat password yang kuat untuk akun Anda',
        ),

        // Password Field with Strength Indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Buat password',
              icon: Icons.lock_outline_rounded,
              validator: Validators.validatePassword,
              isPassword: true,
              obscureText: _obscurePassword,
              onToggleObscure: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),

            // Password Strength Indicator yang lebih compact
            if (_passwordController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _passwordStrength.value / 4,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
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
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 10,
                                color: _getPasswordStrengthColor(),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Validators.getPasswordHint(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Confirm Password Field
        _buildFormField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Password',
          hint: 'Konfirmasi password',
          icon: Icons.lock_reset_outlined,
          validator: _validateConfirmPassword,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleObscure: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
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
              // Logo Section - lebih compact
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

              // Header Section - lebih compact
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

              // Form dengan grouped sections - lebih compact
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Personal Information Section
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 20),

                    // Institutional Information Section
                    _buildInstitutionalSection(),
                    const SizedBox(height: 20),

                    // Account Security Section
                    _buildAccountSecuritySection(),
                    const SizedBox(height: 16),

                    // Terms & Conditions - lebih compact
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: _acceptedTerms
                                  ? AppThemes.primaryColor
                                  : (isDark
                                        ? AppThemes.darkOutline
                                        : Colors.grey.shade400),
                              width: 1.5,
                            ),
                            color: _acceptedTerms
                                ? AppThemes.primaryColor
                                : Colors.transparent,
                          ),
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            activeColor: Colors.transparent,
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptedTerms = !_acceptedTerms;
                              });
                            },
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Saya setuju dengan ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: AppThemes.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' dan ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Kebijakan Privasi',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: AppThemes.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error Widget
                    if (authProvider.error != null) ...[
                      const SizedBox(height: 12),
                      CustomErrorWidget(
                        message: authProvider.error!,
                        onDismiss: () => authProvider.clearError(),
                      ),
                    ],

                    // Register Button - lebih compact
                    const SizedBox(height: 20),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isButtonHovered = true),
                      onExit: (_) => setState(() => _isButtonHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: (_isFormValid && _acceptedTerms)
                              ? AppThemes.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: (_isFormValid && _acceptedTerms)
                                ? AppThemes.primaryColor
                                : AppThemes.neutralColor,
                            width: 1.5,
                          ),
                          boxShadow:
                              _isButtonHovered && _isFormValid && _acceptedTerms
                              ? [
                                  BoxShadow(
                                    color: AppThemes.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: authProvider.isLoading
                            ? const Center(child: LoadingIndicator())
                            : Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: (_isFormValid && _acceptedTerms)
                                      ? _register
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          transform:
                                              _isButtonHovered &&
                                                  _isFormValid &&
                                                  _acceptedTerms
                                              ? Matrix4.translationValues(
                                                  -2,
                                                  0,
                                                  0,
                                                )
                                              : Matrix4.identity(),
                                          child: Icon(
                                            Icons.person_add_outlined,
                                            color:
                                                (_isFormValid && _acceptedTerms)
                                                ? Colors.white
                                                : AppThemes.neutralColor,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Buat Akun',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    (_isFormValid &&
                                                        _acceptedTerms)
                                                    ? Colors.white
                                                    : AppThemes.neutralColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider - lebih compact
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppThemes.darkOutline
                          : Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'atau',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppThemes.darkTextTertiary
                            : AppThemes.hintColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppThemes.darkOutline
                          : Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              // Login Prompt - lebih compact
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : AppThemes.hintColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RouteNames.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppThemes.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Masuk',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppThemes.primaryColor,
                      ),
                    ),
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
