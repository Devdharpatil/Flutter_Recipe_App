import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class AuthHubScreen extends StatefulWidget {
  const AuthHubScreen({super.key});

  @override
  State<AuthHubScreen> createState() => _AuthHubScreenState();
}

class _AuthHubScreenState extends State<AuthHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInDelayedAnimation;
  late Animation<double> _slideUpButtonsAnimation;
  late Animation<double> _fadeInFooterAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Logo fade in and scale effects
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    // Title and subtitle delayed fade in
    _fadeInDelayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    // Buttons slide up animation
    _slideUpButtonsAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    // Footer fade in animation (last element)
    _fadeInFooterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient with animated overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isLightMode 
                      ? const Color(0xFFF8FFF8)
                      : const Color(0xFF1A1E1A),
                  isLightMode
                      ? const Color(0xFFEFFCEF) 
                      : const Color(0xFF212521),
                ],
              ),
            ),
          ),
          
          // Animated background decorative circles for dimension and depth
          Positioned(
            top: -size.height * 0.12,
            right: -size.width * 0.25,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + (0.2 * _scaleAnimation.value),
                  child: Opacity(
                    opacity: 0.08 * _fadeInAnimation.value,
                    child: Container(
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.8),
                            AppTheme.primaryColor.withOpacity(0.0),
                          ],
                          stops: const [0.2, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            bottom: size.height * 0.1,
            left: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + (0.2 * _scaleAnimation.value),
                  child: Opacity(
                    opacity: 0.08 * _fadeInAnimation.value,
                    child: Container(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.8),
                            AppTheme.primaryColor.withOpacity(0.0),
                          ],
                          stops: const [0.2, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Small accent circles for additional visual interest
          Positioned(
            top: size.height * 0.6,
            right: size.width * 0.1,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.05 * _fadeInAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.7),
                          AppTheme.primaryColor.withOpacity(0.0),
                        ],
                        stops: const [0.2, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // Logo and animations
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            children: [
                              // Logo container with elevated design
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isLightMode
                                      ? Colors.white
                                      : const Color(0xFF2A2C2A),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.18),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.08),
                                    width: 1.5,
                                  ),
                                ),
                                child: SizedBox(
                                  width: size.width * 0.25,
                                  height: size.width * 0.25,
                                  child: Image.asset(
                                    'assets/images/logo.png', 
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback icon if image not found
                                      return Icon(
                                        Icons.restaurant_rounded,
                                        size: 64,
                                        color: AppTheme.primaryColor,
                                      );
                                    }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title and subtitle with delayed animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInDelayedAnimation.value,
                        child: Column(
                          children: [
                            // App title
                            Text(
                              'Culinary Compass',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            
                            const SizedBox(height: 14),
                            
                            // Tagline
                            Text(
                              'Your personal journey to culinary excellence',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isLightMode
                                  ? AppTheme.secondaryTextColorLight
                                  : AppTheme.secondaryTextColorDark,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Auth buttons with slide up animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInDelayedAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideUpButtonsAnimation.value),
                          child: Column(
                            children: [
                              // Sign Up Button - Modern, elevated design
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => context.push('/sign_up'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.person_add_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create Account',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Login button - Subtle outline style
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => context.push('/login'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                    side: BorderSide(
                                      color: AppTheme.primaryColor,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: isLightMode
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign In',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Privacy note with fade in animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInFooterAnimation.value,
                        child: Text(
                          'By continuing, you agree to our Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isLightMode
                                ? AppTheme.secondaryTextColorLight
                                : AppTheme.secondaryTextColorDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                      );
                    }
                  ),
                  
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
          
          // Reset button styled as a FAB with tooltip
          Positioned(
            bottom: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeInFooterAnimation.value,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: isLightMode
                        ? Colors.white
                        : const Color(0xFF2A2C2A),
                    elevation: 4,
                    tooltip: 'Reset and view onboarding',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Preferences?'),
                          content: const Text(
                            'This will reset all your preferences and restart the app to show the onboarding experience again. Continue?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Add reset preferences functionality here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Preferences reset. Restart the app to see onboarding.'),
                                  ),
                                );
                              },
                              child: const Text('RESET'),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 