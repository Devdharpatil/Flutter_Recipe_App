import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../../user_favorites/presentation/bloc/user_favorites_event.dart';
import '../bloc/home_bloc.dart';
import '../widgets/section_title.dart';
import '../widgets/category_chip.dart';
import '../widgets/error_section.dart';
import '../widgets/loading_recipe_card.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
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
              return _buildErrorView(state, textTheme);
            }
            
            return const Center(child: Text('Unexpected state'));
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(HomeError state, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    
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

  Widget _buildLoadingView() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium consistent app header that matches Settings screen exactly
        AppHeader(
          title: 'Culinary Compass',
          subtitle: 'Discover delicious recipes',
          isPinned: true,
          expandedHeight: 100, // Exactly match Settings screen
          backgroundColor: colorScheme.background, // Ensure correct background
          actions: [
            // Search action with consistent styling
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: colorScheme.onBackground,
                  size: 24,
                ),
                onPressed: () {
                  context.push('/search');
                },
              ),
            ),
            // Notification action with consistent styling
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onBackground,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
        
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingShimmer(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: LoadingRecipeCard(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildCategoryShimmer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 200,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 250,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedView(HomeLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium consistent app header that matches Settings screen exactly
        AppHeader(
          title: 'Culinary Compass',
          subtitle: 'Discover delicious recipes',
          isPinned: true,
          isFloating: true,
          expandedHeight: 100, // Exactly match Settings screen
          backgroundColor: colorScheme.background, // Ensure correct background
          actions: [
            // Search action with consistent styling
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: colorScheme.onBackground,
                  size: 24,
                ),
                onPressed: () {
                  context.push('/search');
                },
              ),
            ),
            // Notification action with consistent styling
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onBackground,
                  size: 24,
                ),
                onPressed: () {
                  // Notification feature - to be implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
              ),
            ),
          ],
        ),
        
        // Greeting
        SliverToBoxAdapter(
          child: _buildGreeting(),
        ),
        
        // Trending section
        SliverToBoxAdapter(
          child: _buildTrendingSection(state),
        ),
        
        // Categories section
        SliverToBoxAdapter(
          child: _buildCategoriesSection(state),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Get current time to show appropriate greeting
    final hour = DateTime.now().hour;
    String greeting = 'Good evening';
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    }
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What would you like to cook today?',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(HomeLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (state.hasTrendingError) {
      return ErrorSection(
        title: 'Trending Now 🔥',
        message: state.trendingFailure!.message,
        onRetry: () {
          context.read<HomeBloc>().add(const RefreshHomeData());
        },
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Trending Now 🔥',
          onSeeAllPressed: state.hasTrendingRecipes && state.trendingRecipes.length > 5
              ? () {
                  context.pushNamed('trending_recipes');
                }
              : null,
        ),
        if (state.isRefreshing && !state.hasTrendingRecipes)
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: LoadingRecipeCard(),
                );
              },
            ),
          )
        else if (state.hasTrendingRecipes)
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.trendingRecipes.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final recipe = state.trendingRecipes[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 240,
                    child: RecipeCard(
                      recipe: recipe,
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
                  ),
                );
              },
            ),
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 48,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trending recipes available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We couldn\'t load trending recipes right now. This might be due to API limits or network issues.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<HomeBloc>().add(const RefreshHomeData());
                    },
                    icon: const Icon(Icons.refresh, size: 18),
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
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesSection(HomeLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    if (state.hasCategoriesError) {
      return ErrorSection(
        title: 'Categories',
        message: state.categoriesFailure!.message,
        onRetry: () {
          context.read<HomeBloc>().add(const RefreshHomeData());
        },
      );
    }
    
    // Map of icons for different categories
    final Map<String, IconData> categoryIcons = {
      'breakfast': Icons.breakfast_dining,
      'lunch': Icons.lunch_dining,
      'dinner': Icons.dinner_dining,
      'dessert': Icons.cake,
      'appetizer': Icons.tapas,
      'salad': Icons.eco,
      'soup': Icons.soup_kitchen,
      'snack': Icons.cookie,
      'beverage': Icons.local_drink,
      'vegan': Icons.spa,
      // Add more category icons as needed
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Categories',
          onSeeAllPressed: state.hasCategories && state.categories.length > 6
            ? () => context.pushNamed('categories')
            : null,
        ),
        if (state.isRefreshing && !state.hasCategories)
          _buildCategoryShimmer()
        else if (state.hasCategories)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length > 10 ? 10 : state.categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final categoryLower = category.toLowerCase();
                
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(
                        'category_results',
                        pathParameters: {'name': category},
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(categoryLower).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            categoryIcons[categoryLower] ?? Icons.category,
                            color: _getCategoryColor(categoryLower),
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _capitalizeFirstLetter(category),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 40,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  Color _getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'breakfast': Colors.amber,
      'lunch': Colors.green,
      'dinner': Colors.indigo,
      'dessert': Colors.pink,
      'appetizer': Colors.orange,
      'salad': Colors.lightGreen,
      'soup': Colors.cyan,
      'snack': Colors.deepOrange,
      'beverage': Colors.blue,
      'vegan': Colors.teal,
      // Add more categories as needed
    };
    
    return categoryColors[category] ?? Colors.blueGrey;
  }
} 