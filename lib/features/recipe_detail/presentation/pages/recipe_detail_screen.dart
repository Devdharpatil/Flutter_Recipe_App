import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' show ImageFilter;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/di/di_container.dart';
import '../../domain/entities/recipe_detail.dart';
import '../../domain/entities/ingredient_substitutes.dart';
import '../../domain/usecases/get_ingredient_substitutes_usecase.dart';
import '../bloc/recipe_detail_bloc.dart';
import '../bloc/recipe_detail_event.dart';
import '../bloc/recipe_detail_state.dart';
import '../widgets/ingredient_list_item.dart';
import '../widgets/instruction_step_item.dart';
import '../widgets/nutrition_info_widget.dart';
import '../widgets/recipe_meta_info.dart';
import '../../../../features/meal_planning/presentation/widgets/add_to_meal_plan_dialog.dart';
import '../../../../features/meal_planning/presentation/bloc/meal_plan_bloc.dart';
import '../../../../core/widgets/animated_heart_button.dart';

// Class for painting the subtle gloss effect on badges
class GlossEffectPainter extends CustomPainter {
  final double glossOpacity;
  final double glossWidth;
  final double glossPosition;
  
  GlossEffectPainter({
    this.glossOpacity = 0.1,
    this.glossWidth = 0.5,
    this.glossPosition = 0.3,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, glossWidth, glossWidth + 0.1, 1],
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(glossOpacity),
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final double height = size.height * glossPosition;
    final path = Path()
      ..moveTo(0, height)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, height * 2)
      ..lineTo(0, height * 3)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant GlossEffectPainter oldDelegate) {
    return glossOpacity != oldDelegate.glossOpacity ||
           glossWidth != oldDelegate.glossWidth ||
           glossPosition != oldDelegate.glossPosition;
  }
}

// Enhanced haptic feedback utility for sophisticated micro-interactions
class HapticFeedbackManager {
  // Singleton instance for app-wide haptic management
  static final HapticFeedbackManager _instance = HapticFeedbackManager._internal();
  factory HapticFeedbackManager() => _instance;
  HapticFeedbackManager._internal();
  
  // Track the last haptic time to prevent feedback overload
  DateTime? _lastFeedbackTime;
  
  // Configurable parameters
  final int _debounceMs = 200; // Prevent repeated triggers within this timeframe
  
  // Section-specific haptic patterns
  void onSectionToggle(String sectionType, bool isOpening) {
    // Debounce haptic feedback to prevent rapid-fire haptics
    if (_shouldDebounce()) return;
    
    // Record this interaction time
    _lastFeedbackTime = DateTime.now();
    
    // Different sections get slightly different haptic responses for a more delightful UX
    switch (sectionType.toLowerCase()) {
      case 'about':
        // Lightest impact for informational sections
        HapticFeedback.lightImpact();
        break;
      case 'ingredients':
        // Medium impact for core content sections
        isOpening 
            ? HapticFeedback.mediumImpact() 
            : HapticFeedback.lightImpact();
        break;
      case 'instructions':
        // Stronger response for the most important content
        isOpening 
            ? HapticFeedback.mediumImpact() 
            : HapticFeedback.lightImpact();
        break;
      case 'nutrition':
        // Light, clean impact for data sections
        HapticFeedback.selectionClick();
        break;
      default:
        // Default fallback
        HapticFeedback.lightImpact();
    }
  }
  
  // Debounce logic to prevent haptic overload
  bool _shouldDebounce() {
    if (_lastFeedbackTime == null) return false;
    
    final now = DateTime.now();
    final elapsed = now.difference(_lastFeedbackTime!).inMilliseconds;
    return elapsed < _debounceMs;
  }
}

// Stateful animated section header with enhanced micro-interactions
class _AnimatedSectionHeader extends StatefulWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget? trailing;
  final ScrollController scrollController;
  final int sectionIndex; // To create varied effects per section
  @override
  final Key? key;

  const _AnimatedSectionHeader({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.scrollController,
    this.sectionIndex = 0,
    this.trailing,
    this.key,
  });

  @override
  State<_AnimatedSectionHeader> createState() => _AnimatedSectionHeaderState();
}

class _AnimatedSectionHeaderState extends State<_AnimatedSectionHeader> with SingleTickerProviderStateMixin {
  late AnimationController _pressAnimationController;
  late Animation<double> _scaleAnimation;
  double _parallaxOffset = 0.0;
  double _lastScrollPosition = 0.0; // Track previous scroll position
  
  final hapticManager = HapticFeedbackManager();
  
  // Track press state for micro-animations
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Add listener to scroll controller to update parallax effect
    widget.scrollController.addListener(_updateParallax);
    
    // Initialize last scroll position
    if (widget.scrollController.hasClients) {
      _lastScrollPosition = widget.scrollController.position.pixels;
    }
  }
  
  void _updateParallax() {
    if (!mounted || !widget.scrollController.hasClients) return;
    
    // Calculate parallax offset based on scroll position
    final currentScrollPosition = widget.scrollController.position.pixels;
    final viewportDimension = widget.scrollController.position.viewportDimension;
    
    // Determine scroll direction manually
    final isScrollingDown = currentScrollPosition < _lastScrollPosition;
    
    // Create subtle varied effects for different sections
    final baseParallaxFactor = 0.05; // Small factor for subtle effect
    final sectionVariance = 0.01 * widget.sectionIndex;
    final parallaxFactor = baseParallaxFactor + sectionVariance;
    
    // Use different direction based on section index (even/odd)
    final directionMultiplier = widget.sectionIndex % 2 == 0 ? 1.0 : -1.0;
    
    // Calculate new offset with a dampening function for smoother effect
    final dampedScroll = currentScrollPosition * 0.15; // Dampen scroll speed
    final newOffset = dampedScroll * parallaxFactor * directionMultiplier;
    
    // Apply different easing based on scroll direction for more organic feel
    final easedOffset = isScrollingDown 
        ? Curves.easeOutQuint.transform((newOffset.abs() / (viewportDimension * 0.1)).clamp(0.0, 1.0)) * newOffset.sign
        : Curves.easeOutCubic.transform((newOffset.abs() / (viewportDimension * 0.1)).clamp(0.0, 1.0)) * newOffset.sign;
    
    // Only update if the change is significant enough (optimization)
    if ((_parallaxOffset - newOffset).abs() > 0.1) {
      setState(() {
        _parallaxOffset = easedOffset * 5.0; // Scale for visible but subtle effect
      });
    }
    
    // Update last scroll position for next comparison
    _lastScrollPosition = currentScrollPosition;
  }

  @override
  void dispose() {
    // Remove scroll listener
    widget.scrollController.removeListener(_updateParallax);
    _pressAnimationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressAnimationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressAnimationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _pressAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            // Apply parallax transformation
            offset: Offset(_parallaxOffset, 0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.7),
                  ],
                  begin: Alignment(-1.2, 0),
                  end: Alignment(1.0, 0),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: colorScheme.primary.withOpacity(0.08),
                  highlightColor: colorScheme.primary.withOpacity(0.03),
                  splashFactory: InkRipple.splashFactory,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onTap: () {
                    hapticManager.onSectionToggle(widget.title, !widget.isExpanded);
                    widget.onToggle();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 2, 6),
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: widget.isExpanded ? 1.0 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          builder: (context, value, child) {
                            return Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  Colors.transparent,
                                  colorScheme.primary.withOpacity(0.15),
                                  value,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: value * 3.14,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color.lerp(
                                      colorScheme.primary.withOpacity(0.7),
                                      colorScheme.primary,
                                      value,
                                    ),
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                        
                        Expanded(
                          child: Container(
                            height: 1.5,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.5),
                                  colorScheme.primary.withOpacity(0.1),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// First, add a custom painter for the frosted glass effect
class FrostedGlassPainter extends CustomPainter {
  final Color color;
  final double intensity;
  
  FrostedGlassPainter({
    required this.color,
    this.intensity = 0.15,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(intensity * 1.5),
          color.withOpacity(intensity * 0.7),
          color.withOpacity(intensity * 1.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.2, 0.6, 0.9],
        transform: const GradientRotation(0.3),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
    // Add a subtle pattern effect
    final patternPath = Path();
    final double step = 8.0;
    for (double i = 0; i < size.width; i += step) {
      for (double j = 0; j < size.height; j += step) {
        patternPath.addOval(
          Rect.fromCenter(
            center: Offset(i, j), 
            width: 2.0, 
            height: 2.0
          )
        );
      }
    }
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawPath(
      patternPath, 
      Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..style = PaintingStyle.fill
    );
    
    // Add subtle edge highlights
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 10));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 10), highlightPaint);
  }
  
  @override
  bool shouldRepaint(covariant FrostedGlassPainter oldDelegate) {
    return color != oldDelegate.color || intensity != oldDelegate.intensity;
  }
}

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _isAppBarExpanded = true;
  bool _isNearBottom = false;
  final bool _isFixedButtonVisible = false;
  
  // Section visibility state
  bool _isIngredientsVisible = true;
  bool _isInstructionsVisible = true;
  bool _isNutritionVisible = true;
  bool _isSummaryVisible = true;
  bool _isMoreTagsVisible = false;
  
  // Section bookmarking
  bool _isBookmarkPanelVisible = false;
  final Map<String, GlobalKey> _sectionKeys = {
    'About': GlobalKey(),
    'Ingredients': GlobalKey(),
    'Instructions': GlobalKey(),
    'Nutrition': GlobalKey(),
  };
  
  // Track active section for highlighting in bookmark panel
  String _activeSection = 'About';
  
  // UI constants for the bookmark panel
  final double _bookmarkPanelWidth = 32.0; // Even narrower
  final double _bookmarkButtonSize = 28.0; // Smaller button

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Fetch recipe details when screen initializes
    context.read<RecipeDetailBloc>().add(
      FetchRecipeDetail(recipeId: widget.recipeId),
    );
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // Check if app bar is expanded
      final expanded = _scrollController.offset < 200;
      if (_isAppBarExpanded != expanded) {
        setState(() {
          _isAppBarExpanded = expanded;
        });
        if (expanded) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      }
      
      // Calculate when fixed bottom button is completely visible in viewport
      final scrollPosition = _scrollController.position.pixels;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final viewportHeight = _scrollController.position.viewportDimension;
      
      // The fixed button is at the very bottom of the content
      // We need to ensure it's FULLY in view before hiding the floating button
      
      // Calculate how much space is left to scroll
      final remainingScroll = maxScrollExtent - scrollPosition;
      
      // Only hide floating button when fixed button is completely in view
      // This means the remaining scroll should be less than the bottom safe area (approx. 20px)
      // Using a value of 20 ensures the fixed button is fully visible before hiding floating button
      final isNearBottom = remainingScroll < 20;
      
      if (_isNearBottom != isNearBottom) {
        setState(() {
          _isNearBottom = isNearBottom;
        });
      }
      
      // Determine which section is currently in view for active highlighting
      _updateActiveSection();
    }
  }
  
  // Identify which section is currently most visible in the viewport
  void _updateActiveSection() {
    if (!_scrollController.hasClients) return;
    
    // Get the current scroll position
    final scrollPosition = _scrollController.position.pixels;
    
    // Find which section is most visible
    String currentSection = 'About';
    double smallestDistance = double.infinity;
    
    for (final entry in _sectionKeys.entries) {
      final key = entry.value;
      final section = entry.key;
      
      if (key.currentContext != null) {
        final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        
        // Calculate distance from top of viewport
        final distanceFromTop = position.dy;
        
        // Find the section closest to the top of the viewport but not too far above
        if (distanceFromTop < 300 && distanceFromTop > -100) {
          if (distanceFromTop.abs() < smallestDistance) {
            smallestDistance = distanceFromTop.abs();
            currentSection = section;
          }
        }
      }
    }
    
    if (_activeSection != currentSection) {
      setState(() {
        _activeSection = currentSection;
      });
    }
  }
  
  // Scroll to the specified section
  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      // Get the position of the section
      final RenderBox box = key!.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      
      // Calculate the position to scroll to (subtract some padding to account for app bar)
      final scrollPosition = _scrollController.position.pixels + position.dy - 120;
      
      // Scroll to the position with a smooth animation
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      
      // Provide haptic feedback
      HapticFeedback.mediumImpact();
      
      // Close the bookmark panel
      setState(() {
        _isBookmarkPanelVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
        builder: (context, state) {
          if (state is RecipeDetailInitial || state is RecipeDetailLoading) {
            return _buildLoadingView();
          } else if (state is RecipeDetailLoaded) {
            return _buildLoadedView(context, state.recipe);
          } else if (state is RecipeDetailError) {
            return _buildErrorView(context, state.failure.message);
          } else {
            return _buildErrorView(context, 'Unknown state');
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: LoadingIndicator(),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ErrorView(
        message: message,
        onRetry: () => context.read<RecipeDetailBloc>().add(
          FetchRecipeDetail(recipeId: widget.recipeId),
        ),
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, RecipeDetail recipe) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      // Add this GestureDetector to dismiss panel when tapping elsewhere
      onTap: () {
        if (_isBookmarkPanelVisible) {
          setState(() {
            _isBookmarkPanelVisible = false;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, recipe),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(textTheme, recipe.title),
                const SizedBox(height: 16),
                RecipeMetaInfo(
                  readyInMinutes: recipe.readyInMinutes,
                  servings: recipe.servings,
                  healthy: recipe.veryHealthy,
                  sustainable: recipe.sustainable,
                          calories: recipe.nutrition?.nutrients.firstWhere(
                            (nutrient) => nutrient.name.toLowerCase() == 'calories',
                            orElse: () => const Nutrient(name: 'Calories', amount: 0, unit: 'kcal'),
                          ).amount.toInt(),
                ),
                const SizedBox(height: 16),
                _buildDietsAndDishTypes(colorScheme, textTheme, recipe),
                        const SizedBox(height: 20),
                        // About section with key for navigation
                        _buildSectionHeader(
                          context, 
                          'About', 
                          _isSummaryVisible, 
                          () => setState(() => _isSummaryVisible = !_isSummaryVisible),
                          sectionIndex: 0,
                          key: _sectionKeys['About'],
                        ),
                        // About content
                        AnimatedCrossFade(
                          firstChild: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 0),
                            child: _buildSummaryContent(recipe.summary, context),
                          ),
                          secondChild: const SizedBox(height: 0),
                          crossFadeState: _isSummaryVisible
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        ),
              ],
            ),
          ),
        ),
        _buildIngredientsSection(context, recipe.extendedIngredients),
        _buildInstructionsSection(context, recipe.analyzedInstructions),
        if (recipe.nutrition != null)
          _buildNutritionSection(context, recipe.nutrition!),
        SliverToBoxAdapter(
          child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.pagePadding,
                      right: AppDimensions.pagePadding,
                      top: AppDimensions.pagePadding,
                      bottom: AppDimensions.pagePadding,
                    ),
                    child: Column(
                      children: [
                        _buildAddButtons(context, recipe),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Improved floating button with crossfade animation
            Positioned(
              bottom: 24,
              right: 24,
              child: AnimatedOpacity(
                opacity: _isNearBottom ? 0.0 : 0.85,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: AnimatedScale(
                  scale: _isNearBottom ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _startCookingMode(context, recipe),
                      icon: const Icon(Icons.restaurant, size: 18),
                      label: const Text(
                        'Start Cooking',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(160, 46),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Minimalist floating bookmark indicator - moved to top-right
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height * 0.15, // Position at top-right for better visibility
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: Offset(_isBookmarkPanelVisible ? 1.0 : 0.0, 0),
                curve: Curves.easeOutCubic,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBookmarkPanelVisible = !_isBookmarkPanelVisible;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    width: 28, // Smaller
                    height: 28, // Smaller
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.7), // More transparent
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08), // Lighter shadow
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: colorScheme.onPrimary,
                      size: 14, // Smaller icon
                    ),
                  ),
                ),
              ),
            ),
            
            // Ultra-minimal section bookmark panel
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height * 0.14, // Slightly higher than the toggle
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: Offset(_isBookmarkPanelVisible ? 0.0 : 1.0, 0),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: _bookmarkPanelWidth,
                  padding: const EdgeInsets.symmetric(vertical: 4), // Less padding
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6), // Smaller radius
                      bottomLeft: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMinimalBookmarkButton(context, 'About', Icons.info_outline),
                      _buildMinimalBookmarkButton(context, 'Ingredients', Icons.kitchen),
                      _buildMinimalBookmarkButton(context, 'Instructions', Icons.format_list_numbered),
                      _buildMinimalBookmarkButton(context, 'Nutrition', Icons.pie_chart_outline),
                      // More compact divider
                      Divider(height: 4, thickness: 0.5, color: colorScheme.onSurface.withOpacity(0.1)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBookmarkPanelVisible = false;
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: Container(
                          width: _bookmarkPanelWidth,
                          height: 28, // Smaller height
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 12, // Smaller icon
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, RecipeDetail recipe) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
          tag: 'recipe_image_${recipe.id}',
          child: CachedNetworkImage(
            imageUrl: recipe.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
            ),
            // Bottom gradient for better text visibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        title: AnimatedOpacity(
          opacity: _scrollController.hasClients && _scrollController.offset > 200 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        titlePadding: EdgeInsets.symmetric(vertical: 16, horizontal: 48 + statusBarHeight / 2),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
        ),
      ),
      actions: [
        // Add to Plan button
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _addToMealPlan(context, recipe),
            tooltip: 'Add to Meal Plan',
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: _buildFavoriteButton(context, recipe),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareRecipe(recipe),
          ),
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildFavoriteButton(BuildContext context, RecipeDetail recipe) {
    return BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
      buildWhen: (previous, current) {
        // Only rebuild on favorite status changes
        return current is FavoriteToggleSuccess || 
               current is FavoriteToggleLoading || 
               current is FavoriteToggleError ||
               (current is RecipeDetailLoaded && 
                 (previous is! RecipeDetailLoaded || 
                  previous.recipe.isFavorite != current.recipe.isFavorite));
      },
      builder: (context, state) {
        final bool isFavorite = recipe.isFavorite;
        final bool isLoading = state is FavoriteToggleLoading;
        
        if (isLoading) {
          return const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        
        return AnimatedHeartButton(
          isFavorite: isFavorite,
          onToggle: () => context.read<RecipeDetailBloc>().add(
                    ToggleFavoriteRecipe(
                      recipeId: recipe.id,
                      currentStatus: isFavorite,
                    ),
                  ),
          heartColor: Colors.white,
          showBackground: false,
        );
      },
    );
  }

  Widget _buildTitle(TextTheme textTheme, String title) {
    return Text(
      title,
      style: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDietsAndDishTypes(ColorScheme colorScheme, TextTheme textTheme, RecipeDetail recipe) {
    final List<String> allTags = [...recipe.diets, ...recipe.dishTypes];
    
    // Define which tags are considered primary vs secondary
    final Set<String> highPriorityTags = {
      'vegetarian', 'vegan', 'gluten free', 'dairy free', 'keto', 'paleo'
    };
    
    final Set<String> mediumPriorityTags = {
      'whole30', 'pescetarian', 'low carb', 'breakfast', 'lunch', 'dinner',
      'dessert', 'snack', 'appetizer', 'main course'
    };
    
    // Divide tags into priority groups
    final List<String> highPriorityTagsList = [];
    final List<String> mediumPriorityTagsList = [];
    final List<String> lowPriorityTagsList = [];
    
    for (final tag in allTags) {
      final normalizedTag = tag.toLowerCase().replaceAll('_', ' ');
      if (highPriorityTags.contains(normalizedTag)) {
        highPriorityTagsList.add(tag);
      } else if (mediumPriorityTags.contains(normalizedTag)) {
        mediumPriorityTagsList.add(tag);
      } else {
        lowPriorityTagsList.add(tag);
      }
    }
    
    // Determine which tags to show initially (combine high and medium priority)
    final List<String> initialTagsList = [...highPriorityTagsList];
    if (initialTagsList.length < 3 && mediumPriorityTagsList.isNotEmpty) {
      final tagsToAdd = mediumPriorityTagsList.take(3 - initialTagsList.length);
      initialTagsList.addAll(tagsToAdd);
    }
    
    // Secondary tags are all remaining tags
    final List<String> secondaryTagsList = [
      ...mediumPriorityTagsList.skip(initialTagsList.length - highPriorityTagsList.length),
      ...lowPriorityTagsList
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary tags row with toggle at the end
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 6,
                children: initialTagsList.map((tag) => _buildTag(tag, colorScheme, textTheme, isCompact: true)).toList(),
              ),
            ),
            // Toggle button at the end of the row
            if (secondaryTagsList.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMoreTagsVisible = !_isMoreTagsVisible;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    _isMoreTagsVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        
        // Secondary tags section with animation
        if (secondaryTagsList.isNotEmpty)
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 6,
                children: secondaryTagsList.map((tag) => _buildTag(tag, colorScheme, textTheme, isCompact: true)).toList(),
              ),
            ),
            secondChild: const SizedBox(height: 0),
            crossFadeState: _isMoreTagsVisible 
                ? CrossFadeState.showFirst 
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
      ],
    );
  }
  
  Widget _buildTag(String tag, ColorScheme colorScheme, TextTheme textTheme, {bool isCompact = false}) {
    final String formattedTag = tag.replaceAll('_', ' ');
    final Color tagColor = _getTagColor(formattedTag, colorScheme);
    
    return Container(
      padding: isCompact 
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tagColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        formattedTag,
        style: (isCompact ? textTheme.labelSmall : textTheme.bodySmall)?.copyWith(
          color: tagColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
  
  Color _getTagColor(String tag, ColorScheme colorScheme) {
    final String normalizedTag = tag.toLowerCase();
    
    // Diet-based colors
    if (normalizedTag.contains('vegetarian')) return Colors.green.shade700;
    if (normalizedTag.contains('vegan')) return Colors.green.shade900;
    if (normalizedTag.contains('gluten')) return Colors.purple.shade700;
    if (normalizedTag.contains('dairy')) return Colors.blue.shade700;
    if (normalizedTag.contains('keto')) return Colors.orange.shade700;
    if (normalizedTag.contains('paleo')) return Colors.brown.shade700;
    if (normalizedTag.contains('pescetarian')) return Colors.blue.shade800;
    if (normalizedTag.contains('whole30')) return Colors.red.shade700;
    if (normalizedTag.contains('low carb')) return Colors.orange.shade800;
    
    // Meal type colors
    if (normalizedTag.contains('breakfast')) return Colors.amber.shade700;
    if (normalizedTag.contains('lunch')) return Colors.teal.shade700;
    if (normalizedTag.contains('dinner')) return Colors.indigo.shade700;
    if (normalizedTag.contains('snack')) return Colors.pink.shade700;
    if (normalizedTag.contains('appetizer')) return Colors.deepOrange.shade700;
    if (normalizedTag.contains('soup')) return Colors.lightBlue.shade700;
    if (normalizedTag.contains('salad')) return Colors.lightGreen.shade700;
    if (normalizedTag.contains('dessert')) return Colors.purple.shade400;
    if (normalizedTag.contains('drink')) return Colors.cyan.shade700;
    if (normalizedTag.contains('sauce')) return Colors.brown.shade500;
    if (normalizedTag.contains('brunch')) return Colors.amber.shade600;
    
    // Cuisine-based colors
    if (normalizedTag.contains('italian')) return Colors.red.shade800;
    if (normalizedTag.contains('mexican')) return Colors.green.shade800;
    if (normalizedTag.contains('indian')) return Colors.orange.shade800;
    if (normalizedTag.contains('chinese')) return Colors.red.shade700;
    if (normalizedTag.contains('japanese')) return Colors.red.shade900;
    if (normalizedTag.contains('thai')) return Colors.deepPurple.shade700;
    if (normalizedTag.contains('mediterranean')) return Colors.blue.shade900;
    if (normalizedTag.contains('french')) return Colors.indigo.shade800;
    
    // Assign colors deterministically based on the tag string itself to ensure consistency
    final int hash = normalizedTag.hashCode.abs();
    final List<Color> fallbackColors = [
      Colors.teal.shade700,
      Colors.deepPurple.shade600,
      Colors.pink.shade700,
      Colors.blueGrey.shade700,
      Colors.amber.shade800,
      Colors.cyan.shade700,
      Colors.deepOrange.shade600,
      Colors.indigo.shade600,
      Colors.lime.shade800,
      Colors.lightBlue.shade800,
    ];
    
    return fallbackColors[hash % fallbackColors.length];
  }

  Widget _buildSectionHeader(
    BuildContext context, 
    String title, 
    bool isVisible, 
    Function() onToggle, 
    {Widget? trailing, int sectionIndex = 0, Key? key}
  ) {
    return _AnimatedSectionHeader(
      title: title,
      isExpanded: isVisible,
      onToggle: onToggle,
      scrollController: _scrollController,
      sectionIndex: sectionIndex,
      trailing: trailing,
      key: key,
    );
  }

  Widget _buildSummaryContent(String summary, BuildContext context) {
    // More comprehensive HTML parsing
    String plainText = summary
        .replaceAll(RegExp(r'<[^>]*>'), '')  // Remove HTML tags
        .replaceAll('&nbsp;', ' ')           // Replace non-breaking spaces
        .replaceAll('&amp;', '&')            // Replace ampersands
        .replaceAll('&quot;', '"')           // Replace quotes
        .replaceAll('&apos;', "'")           // Replace apostrophes
        .replaceAll('&lt;', '<')             // Replace less than
        .replaceAll('&gt;', '>')             // Replace greater than
        .replaceAll('&mdash;', '—')          // Replace em dashes
        .replaceAll('&ndash;', '–')          // Replace en dashes
        .replaceAll('&hellip;', '…')         // Replace ellipsis
        .replaceAll(RegExp(r'\s+'), ' ')     // Replace multiple whitespaces with one
        .trim();                              // Remove leading/trailing whitespace
    
    return Text(
      plainText,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context, List<Ingredient> ingredients) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 12, AppDimensions.pagePadding, AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildSectionHeader(
              context,
                'Ingredients',
              _isIngredientsVisible,
              () => setState(() => _isIngredientsVisible = !_isIngredientsVisible),
              trailing: _buildCountBadge(context, '${ingredients.length}'),
              sectionIndex: 1,
              key: _sectionKeys['Ingredients'],
            ),
            
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ingredients.length,
                      separatorBuilder: (context, index) => Divider(
                        indent: 16,
                        endIndent: 16,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IngredientListItem(
                    ingredient: ingredient,
                    onTap: () => _showIngredientDetails(context, ingredient),
                          ),
                  );
                },
                    ),
              ),
            ],
          ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _isIngredientsVisible
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      key: bottomChildKey,
                      top: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context, List<InstructionStep> instructions) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 12, AppDimensions.pagePadding, AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildSectionHeader(
              context,
                'Instructions',
              _isInstructionsVisible,
              () => setState(() => _isInstructionsVisible = !_isInstructionsVisible),
              trailing: _buildCountBadge(context, '${instructions.length} steps'),
              sectionIndex: 2,
              key: _sectionKeys['Instructions'],
            ),
            
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  const SizedBox(height: 12),
              if (instructions.isEmpty)
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                  'No detailed instructions available for this recipe.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: instructions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return InstructionStepItem(
                      step: instructions[index],
                      stepNumber: index + 1,
                    );
                  },
                ),
            ],
          ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _isInstructionsVisible
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      key: bottomChildKey,
                      top: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                );
              },
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection(BuildContext context, NutritionInfo nutrition) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 12, AppDimensions.pagePadding, AppDimensions.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Nutrition',
              _isNutritionVisible,
              () => setState(() => _isNutritionVisible = !_isNutritionVisible),
              sectionIndex: 3,
              key: _sectionKeys['Nutrition'],
            ),
            
            AnimatedCrossFade(
              firstChild: Column(
                children: [
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: NutritionInfoWidget(nutrition: nutrition),
            ),
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _isNutritionVisible
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      key: bottomChildKey,
                      top: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButtons(BuildContext context, RecipeDetail recipe) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Main Start Cooking button with reduced size
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton.icon(
          onPressed: () => _startCookingMode(context, recipe),
            icon: const Icon(Icons.restaurant, size: 18),
            label: const Text(
              'Start Cooking',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(46),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                context,
                'Add to List',
                Icons.shopping_cart,
                () => _addToShoppingList(context, recipe),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryButton(
                context,
                'Add to Plan',
                Icons.calendar_today,
                () => _addToMealPlan(context, recipe),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
            letterSpacing: 0.3,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 10),
          minimumSize: const Size.fromHeight(42),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showIngredientDetails(BuildContext context, Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Handle for dragging
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                        Expanded(
                          child: Text(
                    ingredient.name,
                    style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
              if (ingredient.image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                              child: Hero(
                                tag: 'ingredient_image_${ingredient.id}',
                                child: Container(
                                  height: 160,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                    child: CachedNetworkImage(
                      imageUrl: ingredient.image!,
                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                ),
                                ),
                              ),
                            ),
                          ),
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
              Text(
                                  'Details',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildIngredientDetailRow(
                                  context,
                                  Icons.scale,
                                  'Amount',
                                  '${ingredient.amount} ${ingredient.unit}',
                                ),
                                if (ingredient.consistency != null && ingredient.consistency!.isNotEmpty)
                                  _buildIngredientDetailRow(
                                    context,
                                    Icons.opacity,
                                    'Consistency',
                                    ingredient.consistency!,
                                  ),
                                if (ingredient.aisle != null && ingredient.aisle!.isNotEmpty)
                                  _buildIngredientDetailRow(
                                    context,
                                    Icons.shopping_basket,
                                    'Found in',
                                    ingredient.aisle!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSubstitutesSection(context, ingredient.name),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to shopping list'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Add to Shopping List'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showSubstitutesBottomSheet(context, ingredient.name);
                            },
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Substitutes'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIngredientDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstitutesSection(BuildContext context, String ingredientName) {
    final useCase = getIt<GetIngredientSubstitutesUseCase>();
    
    return FutureBuilder(
      future: useCase(IngredientNameParams(ingredientName: ingredientName)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError || 
                   (snapshot.hasData && snapshot.data!.isLeft())) {
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substitutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
              const Text(
                    'No substitutes available for this ingredient.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isRight()) {
          final substitutes = snapshot.data!.getOrElse(() => 
            const IngredientSubstitutes(
              ingredient: '',
              substitutes: [],
              message: '',
            )
          );
          
          if (substitutes.substitutes.isEmpty) {
            return Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Substitutes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...substitutes.substitutes.map((substitute) => 
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.swap_horiz,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(substitute)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        );
          }
          
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substitutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...substitutes.substitutes.map((substitute) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.swap_horiz,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(substitute)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substitutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No substitutes available for this ingredient.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _shareRecipe(RecipeDetail recipe) {
    // Create a shareable message with recipe details
    final String title = recipe.title;
    final String url = recipe.sourceUrl ?? 'No source URL available';
    final String cookTime = '${recipe.readyInMinutes} minutes';
    final String servings = '${recipe.servings} servings';
    
    final String shareText = 'Check out this delicious recipe I found!\n\n'
        '🍳 $title\n'
        '⏱️ Ready in $cookTime\n'
        '👥 Serves $servings\n\n'
        '$url';
    
    // Use share_plus to share the text
    Share.share(shareText, subject: 'Recipe: $title');
  }

  void _startCookingMode(BuildContext context, RecipeDetail recipe) {
    context.push('/cooking_mode/${recipe.id}');
  }

  void _addToShoppingList(BuildContext context, RecipeDetail recipe) {
    // This will be implemented in Phase 4
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added ingredients to shopping list'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToMealPlan(BuildContext context, RecipeDetail recipe) {
    // Show the AddToMealPlanDialog
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Inject the MealPlanBloc for use in the dialog
        return BlocProvider.value(
          value: getIt<MealPlanBloc>(),
          child: AddToMealPlanDialog(
            recipeId: recipe.id,
            recipeTitle: recipe.title,
            recipeImage: recipe.image,
          ),
        );
      },
    );
  }

  void _showSubstitutesBottomSheet(BuildContext context, String ingredientName) {
    final useCase = getIt<GetIngredientSubstitutesUseCase>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle for dragging
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Substitutes for $ingredientName',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Content
                  Expanded(
                    child: FutureBuilder(
                      future: useCase(IngredientNameParams(ingredientName: ingredientName)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError || (snapshot.hasData && snapshot.data!.isLeft())) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.no_food,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No substitutes found',
                                    style: Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'We couldn\'t find any substitutes for $ingredientName',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data!.isRight()) {
                          final substitutes = snapshot.data!.getOrElse(() => 
                            const IngredientSubstitutes(
                              ingredient: '',
                              substitutes: [],
                              message: '',
                            )
                          );
                          
                          if (substitutes.substitutes.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.no_food,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No substitutes found',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'We couldn\'t find any substitutes for $ingredientName',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: substitutes.substitutes.length,
                            itemBuilder: (context, index) {
                              final substitute = substitutes.substitutes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.swap_horiz,
                                            size: 16,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          substitute,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text('Something went wrong'),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Updated count badge with enhanced design
  Widget _buildCountBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.9),
            colorScheme.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Subtle gloss effect overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CustomPaint(
                painter: GlossEffectPainter(
                  glossOpacity: 0.1,
                  glossWidth: 0.6,
                  glossPosition: 0.2,
                ),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
          // Text content
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Ultra-minimal bookmark button - icon only
  Widget _buildMinimalBookmarkButton(BuildContext context, String section, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _activeSection == section;
    
    return Tooltip(
      message: section,
      preferBelow: false,
      verticalOffset: 16,
      child: GestureDetector(
        onTap: () => _scrollToSection(section),
        child: Container(
          width: _bookmarkPanelWidth,
          height: 28, // Smaller height
          margin: const EdgeInsets.symmetric(vertical: 1), // Minimal margin
          decoration: BoxDecoration(
            color: isActive 
                ? colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isActive 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.5),
              size: 14, // Smaller icon
            ),
          ),
        ),
      ),
    );
  }
} 