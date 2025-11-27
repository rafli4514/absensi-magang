import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/validators.dart';
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
  bool _obscurePassword = true;
  bool _isButtonHovered = false;
  bool _isFormValid = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    }
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  // Form field yang compact seperti di register
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
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
      style: TextStyle(
        fontSize: 13,
        color: isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
              // Logo Section - Compact
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

              // Header Section - Compact
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to continue your journey',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
              ),
              const SizedBox(height: 24),

              // Form - Compact Style
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username Field
                    _buildFormField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Enter your username',
                      icon: Icons.person_rounded,
                      validator: Validators.validateUsername,
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    _buildFormField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
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

                    // Forgot Password - Compact
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Forgot password feature coming soon!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppThemes.infoColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          );
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
                          'Forgot Password?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppThemes.primaryColor,
                          ),
                        ),
                      ),
                    ),

                    // Error Widget
                    if (authProvider.error != null) ...[
                      const SizedBox(height: 12),
                      CustomErrorWidget(
                        message: authProvider.error!,
                        onDismiss: () => authProvider.clearError(),
                      ),
                    ],

                    // Login Button - Compact Style
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
                          color: _isFormValid
                              ? AppThemes.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: _isFormValid
                                ? AppThemes.primaryColor
                                : AppThemes.neutralColor,
                            width: 1.5,
                          ),
                          boxShadow: _isButtonHovered && _isFormValid
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
                                  onTap: _isFormValid ? _login : null,
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
                                              _isButtonHovered && _isFormValid
                                              ? Matrix4.translationValues(
                                                  -2,
                                                  0,
                                                  0,
                                                )
                                              : Matrix4.identity(),
                                          child: Icon(
                                            Icons.arrow_forward_outlined,
                                            color: _isFormValid
                                                ? Colors.white
                                                : AppThemes.neutralColor,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Sign In',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _isFormValid
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

              // Divider - Compact
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
                      'or',
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

              // Sign Up Prompt - Compact
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
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
                      Navigator.pushNamed(context, RouteNames.register);
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
                      'Sign Up',
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
