import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/custom_text_field.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        if (authProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, RouteNames.adminHome);
        } else if (authProvider.isMentor) {
          Navigator.pushReplacementNamed(context, RouteNames.mentorHome);
        } else {
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }
      } else if (mounted) {
        GlobalSnackBar.show(
          authProvider.error ?? 'Login gagal',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.show('Terjadi kesalahan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/InternLogoExpand.png',
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Headings
                  Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan masuk untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Inputs
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Masukkan username',
                    icon: Icons.person_outline_rounded,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Username wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Kata Sandi',
                    hint: 'Masukkan kata sandi',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (val) => val == null || val.isEmpty
                        ? 'Kata sandi wajib diisi'
                        : null,
                  ),

                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    height: 50,
                    child: _isLoading
                        ? const Center(child: LoadingIndicator())
                        : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, RouteNames.register),
                        child: const Text(
                          'Daftar',
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
      ),
    );
  }
}