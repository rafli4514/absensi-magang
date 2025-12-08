import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _divisiController = TextEditingController();
  final _instansiController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.nama ?? '';
      _usernameController.text = user.username;
      _divisiController.text = user.divisi ?? '';
      _instansiController.text = user.instansi ?? '';
      _nomorHpController.text = user.nomorHp ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call dengan upload gambar
      await Future.delayed(const Duration(seconds: 2));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Jika ada gambar yang dipilih, upload gambar
      if (_selectedImage != null) {
        // Di sini Anda bisa mengupload gambar ke server
        print('Uploading image: ${_selectedImage!.path}');
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
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
        Navigator.pop(context);
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

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery: $e');
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

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
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

  Widget _buildProfilePicture() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

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
      final authProvider = Provider.of<AuthProvider>(context);
      final user = authProvider.user;

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    required bool isDarkMode,
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
            color: isDarkMode ? AppThemes.darkSurface : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? AppThemes.darkOutline
                  : theme.dividerColor.withOpacity(0.3),
            ),
            boxShadow: [
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
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: keyboardType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppThemes.darkTextPrimary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintText: 'Enter your $label',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppThemes.darkTextSecondary
                          : theme.hintColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _divisiController.dispose();
    _instansiController.dispose();
    _nomorHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Profile', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Stack(
                children: [
                  _buildProfilePicture(),
                  Positioned(
                    bottom: 0,
                    right: 0,
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
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.3 : 0.2,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
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
              const SizedBox(height: 32),

              // Form Fields
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
                icon: Icons.person_rounded,
                validator: Validators.validateUsername,
                keyboardType: TextInputType.text,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 20),
              _buildModernFormField(
                controller: _divisiController,
                label: 'Divisi',
                icon: Icons.business_center_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Divisi is required';
                  }
                  return null;
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 20),
              _buildModernFormField(
                controller: _instansiController,
                label: 'Instansi',
                icon: Icons.school_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Instansi is required';
                  }
                  return null;
                },
                isDarkMode: isDarkMode,
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

              // Update Button
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
                          shadowColor: Colors.black.withOpacity(
                            isDarkMode ? 0.3 : 0.1,
                          ),
                        ),
                        child: Text(
                          'Update Profile',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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

  void _showImageSourceDialog() {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
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
              const SizedBox(height: 8),
              Text(
                'Choose image source',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppThemes.darkTextSecondary
                      : theme.hintColor,
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
