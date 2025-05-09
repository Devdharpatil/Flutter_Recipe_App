import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_step_widget.dart';
import '../widgets/preference_chip.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _pageTransitionAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pageTransitionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(
        pageController: _pageController,
        sharedPreferences: GetIt.instance(),
      ),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          // Reset and forward animation when page changes
          if (state.previousPage != state.currentPage) {
            _animationController.reset();
            _animationController.forward();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                // Beautiful background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color(0xFF1A1D1F),
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[50]!
                            : const Color(0xFF1A1D1F).withOpacity(0.9),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // Enhanced page transition
                PageView(
                  controller: _pageController,
                  physics: const CustomPageViewScrollPhysics(),
                  onPageChanged: (index) {
                    context.read<OnboardingCubit>().onPageChanged(index);
                  },
                  children: [
                    _buildWelcomeScreen(context, state),
                    _buildDiscoverScreen(context, state),
                    _buildSavePlanScreen(context, state),
                    _buildPersonalizationScreen(context, state),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Screen 1: Welcome
  Widget _buildWelcomeScreen(BuildContext context, OnboardingState state) {
    return OnboardingStepWidget(
      // Using the first local image with robust fallback
      imageUrl: 'https://img.freepik.com/free-photo/top-view-table-full-delicious-food-composition_23-2149141352.jpg',
      localImageAsset: 'assets/images/onboarding_image_1.png',
      useNetworkFallback: true,
      title: 'Welcome to Culinary Compass',
      description: 'Your personal guide to discover, cook, and enjoy amazing recipes tailored to your tastes.',
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      onNext: () => context.read<OnboardingCubit>().goToNextPage(),
      onSkip: () {
        context.read<OnboardingCubit>().skipOnboarding();
        context.go('/auth_hub');
      },
    );
  }

  // Screen 2: Discover Highlight
  Widget _buildDiscoverScreen(BuildContext context, OnboardingState state) {
    return OnboardingStepWidget(
      // Using the second local image with robust fallback
      imageUrl: 'https://img.freepik.com/free-photo/flat-lay-batch-cooking-composition_23-2149013932.jpg',
      localImageAsset: 'assets/images/onboarding_image_2.png',
      useNetworkFallback: true,
      title: 'Discover Thousands of Recipes',
      description: 'Search by name, ingredient, or dietary preference. Browse curated collections to find perfect meals for any occasion.',
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      onNext: () => context.read<OnboardingCubit>().goToNextPage(),
      onBack: () => context.read<OnboardingCubit>().goToPreviousPage(),
      onSkip: () {
        context.read<OnboardingCubit>().skipOnboarding();
        context.go('/auth_hub');
      },
    );
  }

  // Screen 3: Save/Plan Highlight
  Widget _buildSavePlanScreen(BuildContext context, OnboardingState state) {
    return OnboardingStepWidget(
      // Using the third local image with robust fallback
      imageUrl: 'https://img.freepik.com/free-photo/meal-planning-notepad-food_23-2148582231.jpg',
      localImageAsset: 'assets/images/onboarding_image_3.png',
      useNetworkFallback: true,
      title: 'Plan, Organize & Cook',
      description: 'Save favorites with a tap, plan your weekly meals, and generate smart shopping lists. Your culinary journey, beautifully organized.',
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      onNext: () => context.read<OnboardingCubit>().goToNextPage(),
      onBack: () => context.read<OnboardingCubit>().goToPreviousPage(),
      onSkip: () {
        context.read<OnboardingCubit>().skipOnboarding();
        context.go('/auth_hub');
      },
    );
  }

  // Screen 4: Personalization (Optional)
  Widget _buildPersonalizationScreen(BuildContext context, OnboardingState state) {
    // Dietary preferences with modern icons
    final dietaryOptions = {
      'Vegan': Icons.eco_outlined,
      'Vegetarian': Icons.spa_outlined,
      'Gluten-Free': Icons.grain_outlined,
      'Dairy-Free': Icons.no_drinks_outlined,
      'Paleo': Icons.egg_outlined,
      'Keto': Icons.fitness_center_outlined,
    };

    // Cooking styles with modern icons
    final styleOptions = {
      'Quick & Easy': Icons.timer_outlined,
      'Budget-Friendly': Icons.attach_money_outlined,
      'Healthy': Icons.favorite_border_outlined,
      'Kid-Friendly': Icons.child_care_outlined,
      'Comfort Food': Icons.restaurant_outlined,
    };

    return OnboardingStepWidget(
      // Image showing personalization/dietary options
      imageUrl: 'https://img.freepik.com/free-photo/healthy-food-assortment-with-copy-space_23-2148700378.jpg',
      title: 'Tailor Your Experience',
      description: 'Select your dietary preferences and cooking style to get personalized recommendations. You can change these anytime in Settings.',
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      nextButtonText: 'Get Started',
      onNext: () async {
        await context.read<OnboardingCubit>().completeOnboarding();
        if (context.mounted) {
          context.go('/auth_hub');
        }
      },
      onBack: () => context.read<OnboardingCubit>().goToPreviousPage(),
      onSkip: () {
        context.read<OnboardingCubit>().skipOnboarding();
        context.go('/auth_hub');
      },
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: child,
                ),
              );
            },
            child: _buildChipFlow(
              context: context, 
              options: dietaryOptions,
              selectedItems: state.selectedDiets,
              onToggle: (diet) => context.read<OnboardingCubit>().toggleDietaryPreference(diet),
              isFirstCategory: true,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category header with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: child,
                ),
              );
            },
            child: _buildChipFlow(
              context: context, 
              options: styleOptions,
              selectedItems: state.selectedCookingStyles,
              onToggle: (style) => context.read<OnboardingCubit>().toggleCookingStyle(style),
              isFirstCategory: false,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build optimized chip flow layouts
  Widget _buildChipFlow({
    required BuildContext context,
    required Map<String, IconData> options,
    required List<String> selectedItems,
    required Function(String) onToggle,
    required bool isFirstCategory,
  }) {
    final size = MediaQuery.of(context).size;
    final hasSelection = selectedItems.isNotEmpty;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 15),
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: isLightMode
              ? Color.alphaBlend(
                  AppTheme.primaryColor.withOpacity(0.05),
                  Colors.white,
                )
              : Color.alphaBlend(
                  AppTheme.primaryColor.withOpacity(0.08),
                  const Color(0xFF1A1D1F),
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelection
                ? AppTheme.primaryColor.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.15),
            width: hasSelection ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header with subtle decoration
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, right: 4.0),
              child: Row(
                children: [
                  Icon(
                    isFirstCategory ? Icons.eco_outlined : Icons.restaurant_menu_outlined,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFirstCategory ? 'Dietary Preferences' : 'Cooking Style',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLightMode
                          ? AppTheme.primaryTextColorLight
                          : AppTheme.primaryTextColorDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (hasSelection) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${selectedItems.length} selected',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Subtle divider 
            if (hasSelection)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Divider(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  height: 1,
                ),
              ),
            
            // Natural flowing wrap without fixed columns
            Wrap(
              spacing: 0, // Let margin on the chip handle spacing
              runSpacing: 0, // Let margin on the chip handle spacing
              alignment: WrapAlignment.start,
              children: _buildOptimizedChips(options, selectedItems, onToggle),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build chips in aesthetically pleasing order
  List<Widget> _buildOptimizedChips(
    Map<String, IconData> options, 
    List<String> selectedItems, 
    Function(String) onToggle
  ) {
    // Sort entries to optimize layout flow - shortest first then longer items
    final entries = options.entries.toList()
      ..sort((a, b) => a.key.length.compareTo(b.key.length));
    
    return entries.map((entry) {
      final isSelected = selectedItems.contains(entry.key);
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(
            0.0,
            isSelected ? -2.0 : 0.0,
          ),
        child: PreferenceChip(
          label: entry.key,
          icon: entry.value,
          isSelected: isSelected,
          onToggle: () => onToggle(entry.key),
        ),
      );
    }).toList();
  }
}

/// Custom scroll physics for PageView with better transition feel
class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80, // More mass for more momentum
        stiffness: 100, // Default is 100
        damping: 1.0, // Smoother damping
      );

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Custom implementation for smoother transitions
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    
    return null;
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    final double page = position.pixels / position.viewportDimension;
    final double targetPage;
    
    if (velocity < -tolerance.velocity) {
      targetPage = page.floor().toDouble();
    } else if (velocity > tolerance.velocity) {
      targetPage = page.ceil().toDouble();
    } else {
      targetPage = page.roundToDouble();
    }
    
    final double target = targetPage * position.viewportDimension;
    return target;
  }
} 