import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/enhanced_category_item.dart';
import '../../../../core/widgets/enhanced_recipe_card.dart';
import '../../../../core/widgets/enhanced_search_bar.dart';
import '../../../../core/widgets/enhanced_section_title.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../../user_favorites/presentation/bloc/user_favorites_event.dart';
import '../bloc/home_bloc.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _headerOpacityAnimation;
  final ValueNotifier<bool> _isScrolled = ValueNotifier<bool>(false);
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    
    // Setup scroll controller
    _scrollController.addListener(_handleScroll);
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _headerOpacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    // Load data
    context.read<HomeBloc>().add(const LoadHomeData());
  }
  
  void _handleScroll() {
    // Calculate scroll progress (0.0 to 1.0) for parallax effects
    final double maxScroll = 150;
    final double currentScroll = _scrollController.offset.clamp(0.0, maxScroll);
    _scrollProgress.value = (currentScroll / maxScroll).clamp(0.0, 1.0);
    
    // Update isScrolled for header behavior
    _isScrolled.value = _scrollController.offset > 10;
    
    if (_isScrolled.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is HomeLoading) {
              return _buildLoadingView();
            }
            
            if (state is HomeLoaded) {
              return _buildLoadedView(state);
            }
            
            if (state is HomeError) {
              return _buildErrorView(state);
            }
            
            return const Center(child: Text('Unexpected state'));
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView(HomeError state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: colorScheme.error.withOpacity(0.8),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! Something went wrong',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomeBloc>().add(const RefreshHomeData());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedView(HomeLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Stack(
      children: [
        // Main scrollable content
        RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const RefreshHomeData());
            await Future.delayed(const Duration(milliseconds: 1500));
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Add top padding for header
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              
              // Greeting Header
              SliverToBoxAdapter(
                child: _buildGreetingHeader(),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: EnhancedSearchBar(
                    onTap: () {
                      context.push('/search');
                    },
                    onFilterTap: () {
                      // Show filter dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filter feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Categories Section
              SliverToBoxAdapter(
                child: _buildCategoriesSection(state),
              ),
              
              // Recommendations Section
              SliverToBoxAdapter(
                child: _buildRecommendationsSection(state),
              ),
              
              // Recipes of the Week Section
              SliverToBoxAdapter(
                child: _buildRecipesOfTheWeekSection(state),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
        
        // Floating header (appears when scrolled)
        ValueListenableBuilder<bool>(
          valueListenable: _isScrolled,
          builder: (context, isScrolled, child) {
            return AnimatedSlide(
              offset: isScrolled ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: FadeTransition(
                opacity: _headerOpacityAnimation,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        'Culinary Compass',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          context.push('/search');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_outline),
                        onPressed: () {
                          context.push('/favorites');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGreetingHeader() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Get current time for appropriate greeting
    final hour = DateTime.now().hour;
    String greeting = 'Good evening';
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    }
    
    // Fetch user display name from authentication state
    // In a real implementation, this would come from AuthBloc or UserProfileCubit
    return FutureBuilder<String>(
      future: _fetchUserDisplayName(),
      builder: (context, snapshot) {
        // Default name if we can't get the actual name
        final username = snapshot.data ?? 'User';
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: colorScheme.onBackground,
                        ),
                        children: [
                          TextSpan(text: 'Hello, '),
                          TextSpan(
                            text: username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What would you like to cook today?',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 18, // Increased size for better visibility
                        fontWeight: FontWeight.w500, // Slightly bolder
                      ),
                    ),
                  ],
                ),
              ),
              
              // User avatar - increased size
              FutureBuilder<String?>(
                future: _fetchUserProfileImage(),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data;
                  return UserAvatar(
                    size: 56, // Increased size
                    imageUrl: imageUrl,
                    fallbackText: username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    fallbackIcon: imageUrl == null ? Icons.person : null,
                    onTap: () {
                      // Navigate to profile
                      context.push('/settings');
                    },
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }

  // Helper method to fetch username from auth state
  Future<String> _fetchUserDisplayName() async {
    // This would be replaced with actual auth state access
    // For example: final user = context.read<AuthBloc>().state.user;
    
    // Mock implementation with 1-second delay to simulate network fetch
    return Future.delayed(
      const Duration(milliseconds: 300), 
      () => 'Annie', // Replace with actual user retrieval
    );
  }
  
  // Helper method to get user profile image
  Future<String?> _fetchUserProfileImage() async {
    // This would be replaced with actual profile image retrieval
    // For example: final profileUrl = context.read<UserProfileCubit>().state.profileImageUrl;
    
    // Mock implementation with small delay to simulate network fetch
    return Future.delayed(
      const Duration(milliseconds: 300), 
      () => 'https://as1.ftcdn.net/v2/jpg/04/67/89/28/1000_F_467892842_X33RMsCz88J28PbE4J9GsHGtVyRTq2uL.jpg',
    );
  }

  Widget _buildCategoriesSection(HomeLoaded state) {
    // Map of detailed food icons for different categories
    final Map<String, IconData> categoryIcons = {
      'breakfast': Icons.free_breakfast_rounded,
      'lunch': Icons.lunch_dining_rounded,
      'dinner': Icons.restaurant_rounded,
      'dessert': Icons.cake_rounded,
      'appetizer': Icons.tapas_outlined,
      'salad': Icons.local_florist_rounded,
      'soup': Icons.ramen_dining_rounded,
      'snack': Icons.cookie_rounded,
      'beverage': Icons.local_cafe_rounded,
      'vegan': Icons.spa_rounded,
      'vegetarian': Icons.grass_rounded,
      'glutenfree': Icons.grain_outlined,
      // Add more detailed icons as needed
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedSectionTitle(
          title: 'Categories',
          onSeeAllPressed: state.hasCategories && state.categories.length > 6
            ? () {
                // Explicitly navigate using the now-named route
                context.go('/categories');
              }
            : null,
        ),
        
        // Categories horizontal list
        SizedBox(
          height: 110, // Slightly increased height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.hasCategories ? state.categories.length.clamp(0, 10) : 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final categoryLower = category.toLowerCase();
              
              // Get color pair for this category
              final colorPair = CategoryColors.getColorPair(index);
              
              // Get icon for this category or use default
              final IconData icon = categoryIcons[categoryLower] ?? Icons.restaurant;
              
              return EnhancedCategoryItem(
                title: category,
                icon: icon,
                backgroundColor: colorPair['background'],
                foregroundColor: colorPair['foreground'],
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pushNamed(
                    'category_results',
                    pathParameters: {'name': category},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedSectionTitle(
          title: 'Trending',
          emoji: '✨',
          onSeeAllPressed: state.hasTrendingRecipes && state.trendingRecipes.length > 5
            ? () {
                context.pushNamed('trending_recipes');
              }
            : null,
        ),
        
        // Recommendations horizontal list
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.hasTrendingRecipes ? state.trendingRecipes.length : 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final recipe = state.trendingRecipes[index];
              
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: EnhancedRecipeCard(
                  recipe: recipe,
                  isHorizontal: true,
                  onTap: () {
                    // Navigate to recipe detail
                    context.push('/recipe/${recipe.id}');
                  },
                  onFavoriteToggle: (isFavorite) {
                    // Add haptic feedback
                    HapticFeedback.lightImpact();
                    
                    // Toggle favorite status via UserFavoritesBloc
                    context.read<UserFavoritesBloc>().add(
                      ToggleFavorite(
                        recipeId: recipe.id,
                        currentStatus: isFavorite,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesOfTheWeekSection(HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedSectionTitle(
          title: 'Recipes of the Week',
          emoji: '🔥',
        ),
        
        // Vertically stacked recipe cards with pagination
        if (state.hasWeeklyRecipes)
          _buildInfiniteRecipeList(state),
      ],
    );
  }
  
  // New method to build the infinite scrolling recipe list
  Widget _buildInfiniteRecipeList(HomeLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // This would typically come from a separate bloc that handles pagination
    // For now, we're simulating it with the existing recipes
    final int maxRecipes = 7; // Show max 7 recipes before prompting reload
    
    // Use weekly recipes instead of trending recipes
    final hasRecipes = state.hasWeeklyRecipes;
    final recipes = state.weeklyRecipes;
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // If we reach the end of the list and we have exactly the max recipes
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            recipes.length == maxRecipes) {
          _showLoadMoreDialog();
        }
        return false;
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recipes.length.clamp(0, maxRecipes),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          
          return EnhancedRecipeCard(
            recipe: recipe,
            isHorizontal: false,
            onTap: () {
              // Navigate to recipe detail
              context.push('/recipe/${recipe.id}');
            },
            onFavoriteToggle: (isFavorite) {
              // Add haptic feedback
              HapticFeedback.lightImpact();
              
              // Toggle favorite status via UserFavoritesBloc
              context.read<UserFavoritesBloc>().add(
                ToggleFavorite(
                  recipeId: recipe.id,
                  currentStatus: isFavorite,
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  // Show dialog for load more
  void _showLoadMoreDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Load More Recipes?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Would you like to load more weekly recipes?',
          style: textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Not Now',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Refresh to load more recipes
              context.read<HomeBloc>().add(const RefreshHomeData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Load More'),
          ),
        ],
      ),
    );
  }
} 