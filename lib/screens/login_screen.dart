import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:agri_gurad/services/auth_service.dart';
import 'package:agri_gurad/config/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result.success) {
            // Update last login timestamp
            await AuthService().updateLastLogin();
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (result.needsEmailVerification) {
            _showEmailVerificationDialog(result.errorMessage ?? 'Please verify your email');
          } else {
            _showErrorSnackBar(result.errorMessage ?? 'Login failed. Please try again.');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('An unexpected error occurred. Please try again.');
        }
      }
    }
  }

  void _showEmailVerificationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Row(
          children: [
            Icon(Icons.email_outlined, color: AppTheme.primaryOrange),
            SizedBox(width: AppConstants.paddingSmall),
            Text('Email Verification Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: AppConstants.paddingMedium),
            const Text(
              'Would you like us to resend the verification email?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await AuthService().resendEmailVerification();
              if (mounted) {
                if (result.success) {
                  _showSuccessSnackBar(result.message ?? 'Verification email sent!');
                } else {
                  _showErrorSnackBar(result.errorMessage ?? 'Failed to send verification email');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Resend Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Header Section
                Text(
                  'Welcome Back! 🌱',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to continue your agriculture journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),

                // Lottie Animation
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Lottie.asset(
                    'assets/lottie/login.json',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildPasswordDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.paddingXLarge),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Forgot Password Link
                Center(
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
      filled: true,
      fillColor: AppTheme.lightGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  InputDecoration _buildPasswordDecoration() {
    return InputDecoration(
      labelText: 'Password',
      hintText: 'Enter your password',
      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      filled: true,
      fillColor: AppTheme.lightGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: AppTheme.primaryGreen),
            SizedBox(width: AppConstants.paddingSmall),
            Text('Reset Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: emailController,
              decoration: _buildInputDecoration(
                label: 'Email Address',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final result = await AuthService().resetPassword(emailController.text.trim());
                if (mounted) {
                  if (result.success) {
                    _showSuccessSnackBar(result.message ?? 'Password reset email sent!');
                  } else {
                    _showErrorSnackBar(result.errorMessage ?? 'Failed to send reset email');
                  }
                }
              }
              emailController.dispose();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              // Navigation to Register
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback toggle,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: toggle,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
