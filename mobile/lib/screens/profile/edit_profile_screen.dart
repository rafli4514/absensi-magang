// lib/screens/profile/edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _divisiController = TextEditingController();
  final _instansiController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController(); // Read-only

  final ImagePicker _imagePicker = ImagePicker();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd'); // Format standar DB

  bool _isLoading = false;
  XFile? _selectedImage;

  // Logic Durasi (Default 3 bulan)
  int _selectedDuration = 3;
  final List<int> _durations = [1, 2, 3, 4, 5, 6, 12];

  @override
  void initState() {
    super.initState();
    // Memuat data setelah frame pertama selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _divisiController.dispose();
    _instansiController.dispose();
    _nomorHpController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        _nameController.text = user.nama ?? '';
        _usernameController.text = user.username;
        _divisiController.text = user.divisi ?? '';
        _instansiController.text = user.instansi ?? '';
        _nomorHpController.text = user.nomorHp ?? '';

        // Load Tanggal
        _tanggalMulaiController.text = user.tanggalMulai ?? '';
        _tanggalSelesaiController.text = user.tanggalSelesai ?? '';

        // Coba hitung durasi dari data yang ada agar UI Chip sesuai
        if (user.tanggalMulai != null && user.tanggalSelesai != null) {
          try {
            DateTime start = DateTime.parse(user.tanggalMulai!);
            DateTime end = DateTime.parse(user.tanggalSelesai!);

            // Hitung selisih bulan secara kasar
            int diffMonths =
                ((end.year - start.year) * 12) + end.month - start.month;

            // Jika selisih hari > 15, anggap tambah 1 bulan (rounding)
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

  // --- DATE LOGIC ---
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
        final isDarkMode = Provider.of<ThemeProvider>(
          context,
          listen: false,
        ).isDarkMode;
        return Theme(
          data: isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
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
        // Menambahkan bulan ke tanggal mulai
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
  // ------------------

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Integrasi ke AuthProvider
      // AuthProvider sekarang sudah otomatis melakukan refreshProfile() jika sukses
      final success = await authProvider.updateUserProfile(
        nama: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        divisi: _divisiController.text.trim(),
        instansi: _instansiController.text.trim(),
        nomorHp: _nomorHpController.text.trim(),
        tanggalMulai: _tanggalMulaiController.text.trim(),
        tanggalSelesai: _tanggalSelesaiController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: AppThemes.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.pop(context); // Kembali ke ProfileScreen dengan data baru
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Failed to update profile'),
              backgroundColor: AppThemes.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) setState(() => _selectedImage = image);
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhotoFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) setState(() => _selectedImage = image);
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isStudent = authProvider.isStudent; // Cek role user
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Profile', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Picture Section ---
              Center(
                child: Stack(
                  children: [
                    _buildProfilePicture(isDarkMode),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode
                                  ? AppThemes.darkSurface
                                  : Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: Icon(
                    Icons.edit_rounded,
                    color: isDarkMode
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                  ),
                  label: Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Personal Info Section ---
              _buildSectionTitle('Personal Info', isDarkMode),
              _buildModernFormField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_rounded,
                validator: Validators.validateName,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 20),
              _buildModernFormField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email_rounded,
                validator: Validators.validateUsername,
                isDarkMode: isDarkMode,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _buildModernFormField(
                controller: _nomorHpController,
                label: 'Nomor HP',
                icon: Icons.phone_rounded,
                validator: Validators.validatePhoneNumber,
                keyboardType: TextInputType.phone,
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 32),

              // --- Internship Info (Conditional) ---
              // Hanya ditampilkan jika user adalah student/magang
              if (isStudent) ...[
                _buildSectionTitle('Internship Info', isDarkMode),
                _buildModernFormField(
                  controller: _divisiController,
                  label: 'Divisi',
                  icon: Icons.business_center_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 20),
                _buildModernFormField(
                  controller: _instansiController,
                  label: 'Instansi / Kampus',
                  icon: Icons.school_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 20),

                // Tanggal Mulai (Date Picker Style)
                _buildDateField(
                  controller: _tanggalMulaiController,
                  label: 'Tanggal Mulai',
                  icon: Icons.calendar_today_rounded,
                  onTap: _selectStartDate,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 20),

                // Durasi Selector
                Text(
                  'Durasi Magang',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
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
                              selectedColor: isDarkMode
                                  ? AppThemes.darkAccentBlue
                                  : AppThemes.primaryColor,
                              labelStyle: TextStyle(
                                color: _selectedDuration == d
                                    ? Colors.white
                                    : (isDarkMode
                                          ? AppThemes.darkTextPrimary
                                          : AppThemes.onSurfaceColor),
                              ),
                              backgroundColor: isDarkMode
                                  ? AppThemes.darkSurface
                                  : Colors.grey.shade100,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Tanggal Selesai (Read Only - Auto Calculated)
                _buildDateField(
                  controller: _tanggalSelesaiController,
                  label: 'Tanggal Selesai (Auto)',
                  icon: Icons.event_available_rounded,
                  isDarkMode: isDarkMode,
                  isReadOnly: true,
                ),

                const SizedBox(height: 40),
              ],

              // --- Update Button ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Update Profile',
                          style: themeProvider.themeMode == ThemeMode.dark
                              ? null // Use default style for dark mode if needed or customize
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

  // --- WIDGET HELPERS ---

  Widget _buildSectionTitle(String title, bool isDarkMode) {
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
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 40,
            height: 3,
            color: isDarkMode
                ? AppThemes.darkAccentBlue
                : AppThemes.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(bool isDarkMode) {
    if (_selectedImage != null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                (isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                    .withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
        ),
      );
    } else {
      // Fallback UI
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? AppThemes.darkSurface : AppThemes.neutralLight,
          border: Border.all(
            color:
                (isDarkMode ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                    .withOpacity(0.3),
            width: 3,
          ),
        ),
        child: Icon(
          Icons.person_rounded,
          size: 50,
          color: isDarkMode ? AppThemes.darkTextSecondary : AppThemes.hintColor,
        ),
      );
    }
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    required bool isDarkMode,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppThemes.darkTextPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            // Warna background tetap abu-abu jika readOnly (memberi efek visual locked)
            color: isDarkMode
                ? (readOnly ? Colors.black12 : AppThemes.darkSurface)
                : (readOnly ? Colors.grey.shade200 : theme.cardColor),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? AppThemes.darkOutline
                  : theme.dividerColor.withOpacity(0.3),
            ),
            // Hilangkan shadow jika readOnly agar terlihat 'flat' (tidak bisa ditekan)
            boxShadow: [
              if (!readOnly)
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      (isDarkMode
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor)
                          .withOpacity(readOnly ? 0.05 : 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  icon,
                  // Warna icon jadi abu-abu jika readOnly
                  color: readOnly
                      ? Colors.grey
                      : (isDarkMode
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboardType,

                  // --- PERUBAHAN UTAMA DI SINI ---
                  // Gunakan enabled: false untuk mematikan TOTAL semua interaksi (klik/hover)
                  enabled: !readOnly,

                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Kita paksa warnanya tetap terbaca meski disabled
                    color: isDarkMode
                        ? (readOnly ? Colors.grey : AppThemes.darkTextPrimary)
                        : (readOnly
                              ? Colors.grey.shade600
                              : theme.textTheme.bodyMedium?.color),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintText: 'Enter $label',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppThemes.darkTextSecondary
                          : theme.hintColor,
                    ),
                  ),
                ),
              ),
              // Icon Gembok (Visual Lock)
              if (readOnly)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    required bool isDarkMode,
    bool isReadOnly = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppThemes.darkTextPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemes.darkSurface
                  : (isReadOnly ? Colors.grey.shade200 : theme.cardColor),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? AppThemes.darkOutline
                    : theme.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        (isDarkMode
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor)
                            .withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDarkMode
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      controller.text.isEmpty
                          ? 'Pilih Tanggal'
                          : controller.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppThemes.darkTextPrimary
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                if (!isReadOnly)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode
                          ? AppThemes.darkTextSecondary
                          : theme.hintColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? AppThemes.darkSurface : theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDarkMode
              ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
              : BorderSide.none,
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.2),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Picture',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppThemes.darkTextPrimary
                      : theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhotoFromCamera();
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  (isDarkMode
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor)
                      .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDarkMode
                  ? AppThemes.darkAccentBlue
                  : AppThemes.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
