import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
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
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _error;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Check if new password and confirm password match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _error = 'New password and confirm password do not match';
          _isLoading = false;
        });
        return;
      }

      // Simulate password change success
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully!'),
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(title: 'Change Password', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      (isDarkMode
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        (isDarkMode
                                ? AppThemes.darkAccentBlue
                                : AppThemes.primaryColor)
                            .withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Security',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? AppThemes.darkTextPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create a strong and secure password',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode
                                  ? AppThemes.darkTextSecondary
                                  : theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Current Password
              _buildModernPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hintText: 'Enter your current password',
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),

              // New Password
              _buildModernPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                hintText: 'Enter your new password',
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                validator: Validators.validatePassword,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),

              // Confirm New Password
              _buildModernPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                hintText: 'Confirm your new password',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                validator: _validateConfirmPassword,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_error != null)
                CustomErrorWidget(
                  message: _error!,
                  onDismiss: () {
                    setState(() {
                      _error = null;
                    });
                  },
                ),

              if (_error != null) const SizedBox(height: 16),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _isLoading
                    ? const LoadingIndicator()
                    : ElevatedButton(
                        onPressed: _changePassword,
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
                          'Change Password',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),

              // Password Requirements
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemes.darkSurface
                      : AppThemes.infoLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppThemes.infoColor.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: AppThemes.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Password Requirements',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? AppThemes.darkTextPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementItem('At least 6 characters', isDarkMode),
                    _buildRequirementItem(
                      'Combination of letters and numbers',
                      isDarkMode,
                    ),
                    _buildRequirementItem('Not easily guessable', isDarkMode),
                    _buildRequirementItem('Avoid common words', isDarkMode),
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

  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
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
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode
                  ? AppThemes.darkTextPrimary
                  : theme.textTheme.bodyMedium?.color,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppThemes.darkTextSecondary
                    : theme.hintColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: isDarkMode
                      ? AppThemes.darkTextSecondary
                      : theme.hintColor,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isDarkMode) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppThemes.successColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppThemes.darkTextSecondary
                    : theme.hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
