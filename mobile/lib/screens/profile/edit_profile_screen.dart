import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _idPesertaMagangController = TextEditingController();
  final _divisiController = TextEditingController();
  final _instansiController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();
  final _mentorController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  bool _isLoading = false;
  XFile? _selectedImage;
  int _selectedDuration = 3;
  final List<int> _durations = [1, 2, 3, 4, 5, 6, 12];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _idPesertaMagangController.dispose();
    _divisiController.dispose();
    _instansiController.dispose();
    _nomorHpController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _mentorController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        _nameController.text = user.nama ?? '';
        _usernameController.text = user.username;
        _idPesertaMagangController.text = user.idPesertaMagang ?? '';
        _divisiController.text = user.divisi ?? '';
        _instansiController.text = user.instansi ?? '';
        _nomorHpController.text = user.nomorHp ?? '';
        _tanggalMulaiController.text = user.tanggalMulai ?? '';
        _tanggalSelesaiController.text = user.tanggalSelesai ?? '';
        _mentorController.text = user.namaMentor ?? '';

        if (user.tanggalMulai != null && user.tanggalSelesai != null) {
          try {
            DateTime start = DateTime.parse(user.tanggalMulai!);
            DateTime end = DateTime.parse(user.tanggalSelesai!);
            int diffMonths =
                ((end.year - start.year) * 12) + end.month - start.month;
            if (end.day - start.day > 15) diffMonths++;
            if (_durations.contains(diffMonths)) {
              _selectedDuration = diffMonths;
            }
          } catch (e) {
            debugPrint("Error parsing date for duration: $e");
          }
        }
      });
    }
  }

  Future<void> _selectStartDate() async {
    DateTime initialDate = DateTime.now();
    if (_tanggalMulaiController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_tanggalMulaiController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Menggunakan Theme default flutter yang sudah diset di main.dart
        return child!;
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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateUserProfile(
        nama: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        idPesertaMagang: _idPesertaMagangController.text.trim(),
        divisi: _divisiController.text.trim(),
        instansi: _instansiController.text.trim(),
        nomorHp: _nomorHpController.text.trim(),
        tanggalMulai: _tanggalMulaiController.text.trim(),
        tanggalSelesai: _tanggalSelesaiController.text.trim(),
        namaMentor: _mentorController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          GlobalSnackBar.show(
            'Profil berhasil diperbarui',
            title: 'Berhasil',
            isSuccess: true,
          );
          Navigator.pop(context);
        } else {
          GlobalSnackBar.show(
            authProvider.error ?? 'Gagal memperbarui profil',
            title: 'Gagal',
            isError: true,
          );
        }
      }
    }
  }

  void _showImageSourceDialog() {
    GlobalSnackBar.show(
      'Fitur ganti foto akan segera tersedia',
      title: 'Info',
      isInfo: true,
    );
  }

  Widget _buildProfilePicture() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedImage != null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppThemes.primaryColor, width: 3),
        ),
        child: ClipOval(
          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
        ),
      );
    } else {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // FIX: Gunakan colorScheme.surfaceContainerHigh pengganti neutralLight/darkSurface
          color: colorScheme.surfaceContainerHigh,
          border: Border.all(color: AppThemes.primaryColor, width: 3),
        ),
        // FIX: Gunakan colorScheme.onSurfaceVariant pengganti hintColor
        child: Icon(Icons.person_rounded,
            size: 50, color: colorScheme.onSurfaceVariant),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // FIX: Gunakan onSurface pengganti darkTextPrimary/onSurfaceColor
              color: colorScheme.onSurface,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 40,
            height: 3,
            // FIX: Gunakan primary color pengganti darkAccentBlue
            color: AppThemes.primaryColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isStudent = authProvider.isStudent;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Profil', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    _buildProfilePicture(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppThemes.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Info Pribadi'),
              CustomTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_rounded,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Username',
                icon: Icons.alternate_email_rounded,
                validator: Validators.validateUsername,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              if (isStudent)
                CustomTextField(
                  controller: _idPesertaMagangController,
                  label: 'ID Peserta Magang (NISN/NIM)',
                  hint: 'Masukkan NISN/NIM',
                  icon: Icons.badge_rounded,
                  keyboardType: TextInputType.text,
                ),
              if (isStudent) const SizedBox(height: 20),
              CustomTextField(
                controller: _nomorHpController,
                label: 'Nomor HP',
                hint: 'Masukkan nomor HP',
                icon: Icons.phone_rounded,
                validator: Validators.validatePhoneNumber,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              if (isStudent) ...[
                _buildSectionTitle('Info Magang'),
                CustomTextField(
                  controller: _divisiController,
                  label: 'Divisi',
                  hint: 'Masukkan divisi',
                  icon: Icons.business_center_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _instansiController,
                  label: 'Instansi / Kampus',
                  hint: 'Masukkan instansi',
                  icon: Icons.school_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _mentorController,
                  label: 'Nama Mentor',
                  hint: 'Nama pembimbing lapangan',
                  icon: Icons.supervisor_account_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _tanggalMulaiController,
                  label: 'Tanggal Mulai',
                  hint: 'Pilih tanggal',
                  icon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _selectStartDate,
                ),
                const SizedBox(height: 20),
                Text(
                  'Durasi Magang',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    // FIX: Gunakan onSurface
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _durations
                        .map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('$d Bulan'),
                              selected: _selectedDuration == d,
                              onSelected: (selected) {
                                if (selected) _updateDuration(d);
                              },
                              // FIX: Gunakan primary color untuk selected color
                              selectedColor: AppThemes.primaryColor,
                              labelStyle: TextStyle(
                                color: _selectedDuration == d
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                              // FIX: Gunakan surfaceContainer untuk background
                              backgroundColor: colorScheme.surfaceContainer,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _tanggalSelesaiController,
                  label: 'Tanggal Selesai (Otomatis)',
                  hint: 'Dihitung otomatis',
                  icon: Icons.event_available_rounded,
                  readOnly: true,
                ),
                const SizedBox(height: 40),
              ],
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          // FIX: Gunakan primary color
                          backgroundColor: AppThemes.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: isDarkMode
                              ? null
                              : const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
