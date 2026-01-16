import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        GlobalSnackBar.show(
          'Kata sandi baru dan konfirmasi tidak cocok',
          isWarning: true,
        );
        return;
      }

      final success = await authProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        GlobalSnackBar.show(
          'Kata sandi berhasil diubah!',
          isSuccess: true,
        );
        Navigator.pop(context);
      } else {
        GlobalSnackBar.show(
          authProvider.error ?? 'Gagal mengubah kata sandi',
          isError: true,
        );
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harap konfirmasi kata sandi baru';
    }
    if (value != _newPasswordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildRequirementItem(String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = theme.extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: colors.success,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    colorScheme.onSurfaceVariant, // Menggunakan warna dari tema
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = theme.extension<AppColors>()!;
    final authProvider = Provider.of<AuthProvider>(context);

    // Gunakan warna primary dari tema
    final primaryColor = colorScheme.primary;

    return Scaffold(
      appBar: CustomAppBar(title: 'Ganti Kata Sandi', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_rounded,
                          color: colorScheme.onPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keamanan Kata Sandi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Buat kata sandi yang kuat dan aman',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Kata Sandi Saat Ini',
                hint: 'Masukkan kata sandi lama',
                icon: Icons.lock_rounded,
                isPassword: true,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                label: 'Kata Sandi Baru',
                hint: 'Masukkan kata sandi baru',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Kata Sandi',
                hint: 'Ulangi kata sandi baru',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 24),
              if (authProvider.error != null)
                CustomErrorWidget(
                  message: authProvider.error!,
                  onDismiss: () => authProvider.clearError(),
                ),
              if (authProvider.error != null) const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: authProvider.isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: Text(
                          'Ubah Kata Sandi',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Gunakan surfaceContainer untuk background adaptif
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: colors.info.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security_rounded,
                            color: colors.info, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Syarat Kata Sandi',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementItem('Minimal 8 karakter'),
                    _buildRequirementItem('Kombinasi huruf dan angka'),
                    _buildRequirementItem('Tidak mudah ditebak'),
                  ],
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
