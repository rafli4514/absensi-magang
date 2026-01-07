import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  // Controllers untuk Data Akun & Pribadi
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers untuk Data Magang
  final _idPesertaMagangController = TextEditingController(); // NISN / NIM
  final _instansiController = TextEditingController();
  final _mentorController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();

  // State untuk Divisi
  String? _selectedDivisi;

  // DATA DIVISI TERBARU (Tanpa kata "Bidang")
  final List<String> _divisiList = [
    'Pemasaran dan Penjualan',
    'Retail SBU',
    'Pembangunan dan Aktivasi',
    'Operasi Pemeliharaan dan Aset',
    'Lainnya',
  ];

  // State untuk Logika Tanggal
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  int _selectedDuration = 3; // Default 3 bulan
  final List<int> _durations = [1, 2, 3, 4, 5, 6, 12];

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _nomorHpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idPesertaMagangController.dispose();
    _instansiController.dispose();
    _mentorController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  // --- LOGIC TANGGAL ---
  Future<void> _selectStartDate() async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppThemes.primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
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

  void _updateDuration(int duration) {
    setState(() {
      _selectedDuration = duration;
      _calculateEndDate();
    });
  }

  void _calculateEndDate() {
    if (_tanggalMulaiController.text.isNotEmpty) {
      try {
        final startDate = DateTime.parse(_tanggalMulaiController.text);
        final endDate = DateTime(
          startDate.year,
          startDate.month + _selectedDuration,
          startDate.day,
        );
        _tanggalSelesaiController.text = _dateFormat.format(endDate);
      } catch (e) {
        debugPrint("Error calculating end date: $e");
      }
    }
  }

  // --- LOGIC REGISTER ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      GlobalSnackBar.show('Kata sandi tidak cocok', isError: true);
      return;
    }

    if (_selectedDivisi == null) {
      GlobalSnackBar.show('Silakan pilih divisi penempatan', isWarning: true);
      return;
    }

    if (_tanggalMulaiController.text.isEmpty ||
        _tanggalSelesaiController.text.isEmpty) {
      GlobalSnackBar.show('Mohon lengkapi periode magang', isWarning: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _usernameController.text.trim(),
        _passwordController.text,
        nama: _namaController.text.trim(),
        idPesertaMagang: _idPesertaMagangController.text.trim(),
        divisi: _selectedDivisi!,
        instansi: _instansiController.text.trim(),
        nomorHp: _nomorHpController.text.trim(),
        tanggalMulai: _tanggalMulaiController.text.trim(),
        tanggalSelesai: _tanggalSelesaiController.text.trim(),
        namaMentor: _mentorController.text.trim(),
        role: 'PESERTA_MAGANG',
      );

      if (success && mounted) {
        GlobalSnackBar.show(
          'Registrasi berhasil! Silakan login.',
          isSuccess: true,
        );
        Navigator.pop(context);
      } else if (mounted) {
        GlobalSnackBar.show(
          authProvider.error ?? 'Gagal registrasi',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) GlobalSnackBar.show('Gagal registrasi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Akun Baru',
          style: TextStyle(
              color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informasi Pribadi'),

                CustomTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Sesuai KTP/KTM',
                  icon: Icons.person_rounded,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'email@example.com',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nomorHpController,
                  label: 'Nomor HP (WhatsApp)',
                  hint: '08xxxxxxxxxx',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhoneNumber,
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Informasi Magang'),

                CustomTextField(
                  controller: _idPesertaMagangController,
                  label: 'NIM / NISN',
                  hint: 'Nomor Induk Mahasiswa/Siswa',
                  icon: Icons.badge_rounded,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _instansiController,
                  label: 'Asal Instansi / Kampus',
                  hint: 'Nama Universitas / Sekolah',
                  icon: Icons.school_rounded,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // --- DROPDOWN DIVISI (DIPERBAIKI) ---
                Text(
                  'Divisi Penempatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDivisi,
                  isExpanded: true,
                  // FIX: Menambahkan style ini agar ukuran font SAMA dengan CustomTextField (13px)
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500, // Samakan ketebalan font
                    fontFamily:
                        Theme.of(context).textTheme.bodyMedium?.fontFamily,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Pilih Divisi',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                    prefixIcon: const Icon(
                      Icons.work_rounded,
                      color: AppThemes.primaryColor,
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  dropdownColor: colorScheme.surfaceContainer,
                  items: _divisiList.map((String division) {
                    return DropdownMenuItem<String>(
                      value: division,
                      child: Text(
                        division,
                        style: TextStyle(
                          fontSize: 13, // Pastikan dropdown item juga 13px
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDivisi = newValue;
                    });
                  },
                  validator: (val) => val == null ? 'Wajib dipilih' : null,
                ),
                // ----------------------------------------------

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _mentorController,
                  label: 'Nama Mentor (Opsional)',
                  hint: 'Nama Pembimbing Lapangan',
                  icon: Icons.supervisor_account_rounded,
                ),
                const SizedBox(height: 16),

                // --- PILIH TANGGAL ---
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _tanggalMulaiController,
                        label: 'Mulai',
                        hint: 'Tgl Mulai',
                        icon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: _selectStartDate,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _tanggalSelesaiController,
                        label: 'Selesai',
                        hint: 'Otomatis',
                        icon: Icons.event_available_rounded,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Durasi Chips
                Text(
                  'Durasi Magang:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$d Bulan'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) _updateDuration(d);
                          },
                          selectedColor: AppThemes.primaryColor,
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : colorScheme.outline.withOpacity(0.3))),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('Keamanan Akun'),

                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Buat username unik',
                  icon: Icons.person_outline_rounded,
                  validator: Validators.validateUsername,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  hint: 'Minimal 8 karakter',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Sandi',
                  hint: 'Ulangi kata sandi',
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  validator: (val) => Validators.validateConfirmPassword(
                      val, _passwordController.text),
                ),

                const SizedBox(height: 40),

                // Button Daftar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _isLoading
                      ? const LoadingIndicator()
                      : ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppThemes.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor:
                                AppThemes.primaryColor.withOpacity(0.4),
                          ),
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: AppThemes.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppThemes.primaryColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 30,
            height: 2,
            color: AppThemes.primaryColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
