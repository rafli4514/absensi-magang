import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
          _usernameController.text.trim(), _passwordController.text.trim());

      if (!mounted) return;

      if (success) {
        final user = authProvider.user;
        final name = user?.nama ?? user?.username ?? 'User';

        GlobalSnackBar.show(
          'Selamat datang, $name!',
          title: 'Login Berhasil',
          isSuccess: true,
        );

        // LOGIKA REDIRECT BERDASARKAN ROLE
        if (authProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, RouteNames.adminHome);
        } else if (authProvider.isMentor) {
          Navigator.pushReplacementNamed(context, RouteNames.mentorHome);
        } else {
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }
      } else {
        final errorMsg = authProvider.error;
        GlobalSnackBar.show(
          errorMsg ?? 'Periksa kembali username dan password Anda.',
          title: 'Login Gagal',
          isError: true,
        );
        authProvider.clearError();
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.show(
          'Terjadi kesalahan sistem: $e',
          title: 'System Error',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/images/InternLogoExpand.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Selamat Datang Kembali', // Translate
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk untuk melanjutkan aktivitasmu', // Translate
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // FORM SECTION
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _usernameController,
                              label: 'Username',
                              hint: 'Masukkan username', // Translate
                              icon: Icons.person_rounded,
                              validator: Validators.validateUsername,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Kata Sandi', // Translate
                              hint: 'Masukkan kata sandi', // Translate
                              icon: Icons.lock_outline_rounded,
                              validator: Validators.validatePassword,
                              isPassword: true,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  GlobalSnackBar.show(
                                    'Fitur reset password akan segera tersedia.',
                                    title: 'Info',
                                    isWarning: true,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Lupa Kata Sandi?', // Translate
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppThemes.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            if (authProvider.error != null) ...[
                              const SizedBox(height: 16),
                              CustomErrorWidget(
                                message: authProvider.error!,
                                onDismiss: () => authProvider.clearError(),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: authProvider.isLoading
                                  ? const Center(child: LoadingIndicator())
                                  : ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppThemes.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        'Masuk', // Translate
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // FOOTER SECTION
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: isDark
                                      ? AppThemes.darkOutline
                                      : Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'atau', // Translate
                              style: TextStyle(
                                fontSize: 12,
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
                                      : Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum punya akun?", // Translate
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppThemes.darkTextSecondary
                                  : AppThemes.hintColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.register);
                            },
                            child: const Text(
                              'Daftar Sekarang', // Translate
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppThemes.primaryColor,
                              ),
                            ),
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
        },
      ),
    );
  }
}
