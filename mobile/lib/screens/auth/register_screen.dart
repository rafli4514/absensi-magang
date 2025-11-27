import 'package:flutter/material.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonHovered = false;
  bool _isFormValid = false;
  PasswordStrength _passwordStrength = PasswordStrength.weak;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
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
        return 'Weak';
      case PasswordStrength.medium:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Good';
      case PasswordStrength.veryStrong:
        return 'Strong';
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Logo Section - Minimal
              const SizedBox(height: 40),
              Hero(
                tag: 'app_logo',
                child: Center(
                  child: Image.asset(
                    'assets/images/InternLogoExpand.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Header Section - Minimal
              Text(
                'Create Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your internship journey with us',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                ),
              ),
              const SizedBox(height: 40),

              // Form - No Card, Direct on Background
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: AppThemes.primaryColor,
                        ),
                        filled: true,
                        fillColor: theme.cardTheme.color,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 20),

                    // Password Field with Strength Indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Create strong password',
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppThemes.primaryColor,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppThemes.primaryColor,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppThemes.darkOutline
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppThemes.darkOutline
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppThemes.primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppThemes.darkTextPrimary
                                : AppThemes.onSurfaceColor,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => _checkPasswordStrength(value),
                        ),

                        // Password Strength Indicator
                        if (_passwordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: _passwordStrength.value / 4,
                                        backgroundColor: isDark
                                            ? AppThemes.darkOutline
                                            : Colors.grey.shade300,
                                        color: _getPasswordStrengthColor(),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getPasswordStrengthText(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: _getPasswordStrengthColor(),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Use 8+ characters with letters, numbers & symbols',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppThemes.darkTextTertiary
                                        : AppThemes.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(
                          Icons.lock_reset_outlined,
                          color: AppThemes.primaryColor,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppThemes.primaryColor,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppThemes.darkOutline
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppThemes.darkOutline
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppThemes.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: _validateConfirmPassword,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.done,
                    ),

                    // Terms & Conditions - Modern Checkbox
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _acceptedTerms
                                  ? AppThemes.primaryColor
                                  : (isDark
                                        ? AppThemes.darkOutline
                                        : Colors.grey.shade400),
                              width: 2,
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
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                    text: 'I agree to the ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppThemes.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppThemes.darkTextSecondary
                                          : AppThemes.hintColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: theme.textTheme.bodySmall?.copyWith(
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
                      const SizedBox(height: 16),
                      CustomErrorWidget(
                        message: authProvider.error!,
                        onDismiss: () => authProvider.clearError(),
                      ),
                    ],

                    // Register Button - Modern Outline Style
                    const SizedBox(height: 24),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isButtonHovered = true),
                      onExit: (_) => setState(() => _isButtonHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: (_isFormValid && _acceptedTerms)
                              ? AppThemes.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: (_isFormValid && _acceptedTerms)
                                ? AppThemes.primaryColor
                                : AppThemes.neutralColor,
                            width: 2,
                          ),
                          boxShadow:
                              _isButtonHovered && _isFormValid && _acceptedTerms
                              ? [
                                  BoxShadow(
                                    color: AppThemes.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: authProvider.isLoading
                            ? const Center(child: LoadingIndicator())
                            : Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: (_isFormValid && _acceptedTerms)
                                      ? _register
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
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
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Create Account',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
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

              // Divider - Minimal
              const SizedBox(height: 32),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: theme.textTheme.bodySmall?.copyWith(
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

              // Login Prompt - Minimal
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppThemes.darkTextSecondary
                          : AppThemes.hintColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RouteNames.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppThemes.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppThemes.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
