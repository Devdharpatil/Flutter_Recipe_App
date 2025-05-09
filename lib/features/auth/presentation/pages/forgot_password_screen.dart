import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        PasswordResetRequested(
          email: _emailController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isLightMode 
                      ? const Color(0xFFFAFFFB)
                      : const Color(0xFF1A1E1A),
                  isLightMode
                      ? const Color(0xFFF8FDF8) 
                      : const Color(0xFF202420),
                ],
              ),
            ),
          ),
      
          // App Bar with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Reset Password',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Main content
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // We don't navigate away on success; the user needs to see the confirmation
            },
            builder: (context, state) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeInAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                
                                // Reset password icon
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isLightMode 
                                        ? AppTheme.primaryColor.withOpacity(0.1)
                                        : AppTheme.primaryColor.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.lock_reset_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Title
                                Center(
                                  child: Text(
                                    'Forgot Your Password?',
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Instruction text
                                Center(
                                  child: Text(
                                    'Enter your account\'s email address and we\'ll send you a link to reset your password.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: isLightMode
                                        ? AppTheme.secondaryTextColorLight
                                        : AppTheme.secondaryTextColorDark,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 40),
                                
                                // Email field
                                Container(
                                  margin: const EdgeInsets.only(bottom: 32),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      hintText: 'Enter your email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: isLightMode 
                                        ? Colors.white 
                                        : const Color(0xFF2A2C2A),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: AppTheme.primaryColor,
                                      ),
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                    ),
                                  ),
                                ),
                                
                                // Feedback message - Success
                                if (state is PasswordResetSuccess)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 32),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLightMode
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFF1B2E1C),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: AppTheme.primaryColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Reset Link Sent',
                                                style: textTheme.titleMedium?.copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Password reset instructions sent to your email. Please check your inbox (and spam folder).',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  color: isLightMode
                                                    ? AppTheme.primaryTextColorLight
                                                    : AppTheme.primaryTextColorDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                // Error message
                                else if (state is AuthFailure && state.message.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 32),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLightMode
                                          ? const Color(0xFFFFEFEF)
                                          : const Color(0xFF3A2A2A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE53935),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          child: const Icon(
                                            Icons.error_rounded,
                                            color: Color(0xFFE53935),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Error',
                                                style: textTheme.titleMedium?.copyWith(
                                                  color: const Color(0xFFE53935),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                state.message,
                                                style: textTheme.bodyMedium?.copyWith(
                                                  color: isLightMode
                                                    ? AppTheme.primaryTextColorLight
                                                    : AppTheme.primaryTextColorDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // Reset password button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading || state is PasswordResetSuccess
                                        ? null
                                        : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: state is PasswordResetSuccess
                                        ? AppTheme.primaryColor.withOpacity(0.3)
                                        : null,
                                      elevation: 4,
                                      shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: state is AuthLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            state is PasswordResetSuccess
                                                ? 'Return to Login'
                                                : 'Send Reset Link',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Return to login link
                                if (!(state is PasswordResetSuccess))
                                  Center(
                                    child: TextButton(
                                      onPressed: () => context.push('/login'),
                                      child: Text(
                                        'Back to Login',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              );
            },
          ),
        ],
      ),
    );
  }
} 