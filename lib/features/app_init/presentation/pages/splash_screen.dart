import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show Random;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/app_initialization_cubit.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Multiple animation controllers for complex sequences
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _exitAnimationController;
  
  // Logo animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoRotateAnimation;
  
  // Background animations
  late Animation<double> _backgroundGradientAnimation;
  
  // Accent animations for particles
  late Animation<double> _particleOpacityAnimation;
  
  // Exit animations
  late Animation<double> _exitScaleAnimation;
  late Animation<double> _exitOpacityAnimation;
  
  // Random generator for particle effects
  final Random _random = math.Random();
  
  // Track if navigation has been triggered
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    
    // Setup system UI for immersive experience
    _setupSystemUI();
    
    // Setup all animation controllers
    _setupAnimationControllers();
    
    // Setup all animations
    _setupAnimations();
    
    // Start the animation sequence
    _startAnimationSequence();
    
    // Initialize app state
    context.read<AppInitializationCubit>().initializeApp();
  }

  void _setupSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [], // Hide status bar and navigation for immersive feel
    );
    
    // Ensure proper system UI colors to avoid black bars
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void _setupAnimationControllers() {
    // Logo animation controller - handles the main logo animation
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Background animation controller - handles gradient and backdrop effects
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    // Particle animation controller - handles floating elements
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    
    // Exit animation controller - handles transition out
    _exitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _setupAnimations() {
    // Logo scale animation - elegant entrance
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
    ]).animate(_logoAnimationController);
    
    // Logo opacity animation
    _logoOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
    ]).animate(_logoAnimationController);
    
    // Subtle logo rotation for dynamic feel
    _logoRotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    
    // Background gradient animation
    _backgroundGradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Particle opacity animation
    _particleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(
      CurvedAnimation(
        parent: _particleAnimationController,
        curve: const Interval(0.2, 0.4, curve: Curves.easeInOut),
      ),
    );
    
    // Exit scale animation
    _exitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: Curves.easeInCubic,
      ),
    );
    
    // Exit opacity animation
    _exitOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: Curves.easeInCubic,
      ),
    );
  }

  void _startAnimationSequence() {
    // Start the background animation immediately
    _backgroundAnimationController.forward();
    
    // Add a slight delay before starting the logo animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
    });
    
    // Add a longer delay before showing particle effects
    Future.delayed(const Duration(milliseconds: 800), () {
      _particleAnimationController.forward();
    });
  }

  void _handleNavigation(BuildContext context, AuthState authState) {
    if (_isNavigating) return;
    
    _isNavigating = true;
    
    // Play exit animation
    _exitAnimationController.forward().then((_) {
      // Restore system UI before navigation
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      
      // Navigate based on auth state
      switch (authState) {
        case AuthState.firstLaunch:
          context.go('/onboarding');
          break;
        case AuthState.authenticated:
          context.go('/home');
          break;
        case AuthState.unauthenticated:
        default:
          context.go('/auth_hub');
          break;
      }
    });
  }
  
  // Generate random particles for the background effect
  List<Widget> _buildParticles(int count, double maxSize) {
    return List.generate(
      count,
      (index) {
        final size = _random.nextDouble() * maxSize;
        final posX = _random.nextDouble();
        final posY = _random.nextDouble();
        final opacity = _random.nextDouble() * 0.6;
        final duration = 3000 + _random.nextInt(5000);
        
        return Positioned(
          left: MediaQuery.of(context).size.width * posX,
          top: MediaQuery.of(context).size.height * posY,
          child: AnimatedBuilder(
            animation: _particleOpacityAnimation,
            builder: (context, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: duration),
                curve: Curves.easeInOut,
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.primaryLightColor.withOpacity(opacity * _particleOpacityAnimation.value)
                    : AppColors.primary.withOpacity(opacity * _particleOpacityAnimation.value),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _particleAnimationController.dispose();
    _exitAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppInitializationCubit, AppInitializationState>(
      listener: (context, state) {
        if (state.isCompleted) {
          _handleNavigation(context, state.authState!);
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _exitAnimationController,
          _backgroundAnimationController
        ]),
        builder: (context, child) {
          return Scaffold(
            body: Transform.scale(
              scale: _exitScaleAnimation.value,
              child: Opacity(
                opacity: _exitOpacityAnimation.value,
                child: Container(
                  // Animated gradient background
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).brightness == Brightness.light
                            ? Color.lerp(
                                const Color(0xFFFCFCFA),
                                const Color(0xFFF8F8F6),
                                _backgroundGradientAnimation.value)!
                            : Color.lerp(
                                const Color(0xFF1A1D1F),
                                const Color(0xFF1D2023),
                                _backgroundGradientAnimation.value)!,
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color(0xFF16181A),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Particle effects
                      ..._buildParticles(15, 6.0),
                      
                      // Main content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo with animations
                            AnimatedBuilder(
                              animation: _logoAnimationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _logoRotateAnimation.value * math.pi * 2,
                                  child: Opacity(
                                    opacity: _logoOpacityAnimation.value,
                                    child: Transform.scale(
                                      scale: _logoScaleAnimation.value,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: _buildLogo(context),
                            ),
                            
                            // Loading indicator
                            BlocBuilder<AppInitializationCubit, AppInitializationState>(
                              builder: (context, state) {
                                if (state.isInitializing) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 48.0),
                                    child: _buildLoadingIndicator(context),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
  
  Widget _buildLogo(BuildContext context) {
    // Create a beautiful app logo with a custom design
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: Theme.of(context).brightness == Brightness.light
              ? [
                  AppColors.primary.withOpacity(0.1),
                  Colors.white.withOpacity(0.9),
                ]
              : [
                  AppColors.primary.withOpacity(0.2),
                  const Color(0xFF1D2023).withOpacity(0.8),
                ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.1)
                : Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Container(
              width: MediaQuery.of(context).size.width * 0.28,
              height: MediaQuery.of(context).size.width * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.primary.withOpacity(0.5),
                  width: 2.0,
                ),
              ),
            ),
            
            // Inner design - fork and knife forming a compass
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              height: MediaQuery.of(context).size.width * 0.18,
              child: CustomPaint(
                painter: CompassUtensils(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.primaryTextColorLight
                      : AppTheme.primaryTextColorDark,
                  accentColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator(BuildContext context) {
    return Column(
      children: [
        // Sophisticated loading animation
        SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: LoadingRingPainter(
              animation: _logoAnimationController,
              color: AppColors.primary,
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Tagline text
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _logoAnimationController.value > 0.7 ? 1.0 : 0.0,
            child: Text(
              "Your Culinary Journey Awaits",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.secondaryTextColorLight
                    : AppTheme.secondaryTextColorDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for compass with utensils design
class CompassUtensils extends CustomPainter {
  final Color color;
  final Color accentColor;
  
  CompassUtensils({required this.color, required this.accentColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
      
    final Paint accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw fork
    final forkTop = center.translate(0, -radius);
    final forkBottom = center.translate(0, radius * 0.7);
    
    // Fork handle
    canvas.drawLine(forkBottom, center.translate(0, -radius * 0.3), paint);
    
    // Fork tines
    canvas.drawLine(forkTop, center.translate(0, -radius * 0.3), accentPaint);
    canvas.drawLine(center.translate(-radius * 0.2, -radius * 0.7), 
                   center.translate(-radius * 0.2, -radius * 0.3), paint);
    canvas.drawLine(center.translate(radius * 0.2, -radius * 0.7), 
                   center.translate(radius * 0.2, -radius * 0.3), paint);
    
    // Draw knife
    final knifeTop = center.translate(radius * 0.7, 0);
    final knifeBottom = center.translate(-radius * 0.7, 0);
    
    // Knife handle
    canvas.drawLine(knifeBottom, center.translate(-radius * 0.2, 0), paint);
    
    // Knife blade
    canvas.drawLine(center.translate(-radius * 0.2, 0), knifeTop, accentPaint);
    
    // Draw compass dot
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, 4, dotPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for loading animation
class LoadingRingPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  LoadingRingPainter({required this.animation, required this.color}) 
      : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;
    
    // Animated arc for loading indicator
    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * animation.value;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    
    // Draw shimmer dots around the circle
    final dotPaint = Paint()
      ..color = color.withOpacity(0.6);
      
    final dotsCount = 8;
    for (int i = 0; i < dotsCount; i++) {
      final angle = startAngle + (math.pi * 2 / dotsCount) * i;
      final offset = animation.value * math.pi * 2 / 3;
      final dotRadius = 2.0 + 1.0 * math.sin((animation.value * 5 + i / dotsCount) * math.pi * 2);
      
      final dotCenter = Offset(
        center.dx + (radius + 5) * math.cos(angle + offset),
        center.dy + (radius + 5) * math.sin(angle + offset),
      );
      
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }
  
  @override
  bool shouldRepaint(LoadingRingPainter oldDelegate) => true;
} 