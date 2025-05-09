import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/app_header.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_suggestion_item.dart';
import '../widgets/recent_search_item.dart';
import '../widgets/search_theme.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/filter_chip_group.dart';
import '../widgets/trending_search_card.dart';
import '../widgets/category_card.dart';
import '../../domain/entities/filter_options.dart';

class SearchInputScreen extends StatefulWidget {
  const SearchInputScreen({super.key});

  @override
  State<SearchInputScreen> createState() => _SearchInputScreenState();
}

class _SearchInputScreenState extends State<SearchInputScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _recentSearchesController = ScrollController();
  
  // For trending searches
  final List<String> _trendingSearches = [
    'Pasta', 'Chicken', 'Vegetarian', 'Dessert', 'Quick Meals',
    'Breakfast', 'Healthy', 'Soup', 'Salad', 'Baking'
  ];
  
  // Controllers for animations
  late final AnimationController _headerAnimationController;
  late final AnimationController _searchBarAnimationController;
  late final AnimationController _contentAnimationController;
  
  // Selected filter options
  FilterOptions _filterOptions = FilterOptions.empty;
  bool _isFilterExpanded = false;
  
  // Diet chips
  final List<String> _popularDiets = [
    'Vegetarian', 'Vegan', 'Gluten Free', 'Keto', 'Low Carb'
  ];
  
  // Recommended categories
  final List<Map<String, dynamic>> _recommendedCategories = [
    {'title': 'Quick & Easy', 'icon': Icons.timer_outlined},
    {'title': 'Budget Friendly', 'icon': Icons.savings_outlined},
    {'title': 'Healthy Options', 'icon': Icons.favorite_border},
    {'title': 'Seasonal', 'icon': Icons.eco_outlined},
    {'title': 'Comfort Food', 'icon': Icons.nightlife_outlined},
    {'title': 'Kid Friendly', 'icon': Icons.child_care_outlined},
  ];

  @override
  void initState() {
    super.initState();
    // Set up animation controllers
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Load recent searches when screen is opened
    context.read<SearchBloc>().add(const LoadRecentSearches());
    
    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _searchBarAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _contentAnimationController.forward();
    });
    
    // Request focus after animations
    Future.delayed(const Duration(milliseconds: 800), () {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _recentSearchesController.dispose();
    _headerAnimationController.dispose();
    _searchBarAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchSubmitted(
        query: query.trim(),
        filterOptions: _filterOptions.isEmpty ? null : _filterOptions,
      ));
      // Navigate to search results
      context.push('/search_results?query=${Uri.encodeComponent(query.trim())}');
    }
  }

  void _onSuggestionTapped(String suggestion) {
    _searchController.text = suggestion;
    _onSearchSubmitted(suggestion);
  }

  void _onRecentSearchTapped(String search) {
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _onTrendingSearchTapped(String search) {
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const ClearSearch());
    _searchFocusNode.requestFocus();
  }

  void _deleteRecentSearch(String query) {
    // Implement delete functionality for recent searches
    // For now, let's just refresh the recent searches
    context.read<SearchBloc>().add(const LoadRecentSearches());
    // TODO: Add a DeleteRecentSearch event to the bloc and implement it
  }

  void _openFilterScreen() {
    context.push('/search_filter').then((value) {
      // Refresh the screen after returning from filter
      setState(() {});
    });
  }
  
  void _toggleFilterExpanded() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
  }
  
  void _onDietFiltersChanged(List<String> selectedDiets) {
    setState(() {
      _filterOptions = _filterOptions.copyWith(diets: selectedDiets);
    });
  }
  
  void _onMealTypesChanged(List<String> selectedMealTypes) {
    setState(() {
      _filterOptions = _filterOptions.copyWith(mealTypes: selectedMealTypes);
    });
  }
  
  void _resetFilters() {
    setState(() {
      _filterOptions = FilterOptions.empty;
    });
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(const LoadMoreResults());
    }
  }
  
  bool get _isBottom {
    if (!_recentSearchesController.hasClients) return false;
    final maxScroll = _recentSearchesController.position.maxScrollExtent;
    final currentScroll = _recentSearchesController.offset;
    // Load more when within 80% of the end
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Animated premium search header
            AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _headerAnimationController.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _headerAnimationController.value)),
                    child: _buildHeader(colorScheme, textTheme),
                  ),
                );
              },
            ),
            
            // Animated search bar
            AnimatedBuilder(
              animation: _searchBarAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _searchBarAnimationController.value,
                  child: Transform.translate(
                    offset: Offset(0, 15 * (1 - _searchBarAnimationController.value)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: _buildSearchField(),
                    ),
                  ),
                );
              },
            ),
            
            // Filter panel containing quick filters and advanced filters
            AnimatedBuilder(
              animation: _searchBarAnimationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _searchBarAnimationController.value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _searchBarAnimationController.value)),
                    child: _buildFilterPanel(colorScheme, textTheme),
                  ),
                );
              },
            ),
            
            // Content
            Expanded(
              child: AnimatedBuilder(
                animation: _contentAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _contentAnimationController.value,
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        // Show recent searches if search is empty
                        if (state is RecentSearchesLoaded) {
                          return _buildSearchContent(
                            recentSearches: state.recentSearches,
                          );
                        }
                        
                        // Show loading indicator when getting autocomplete suggestions
                        if (state is AutocompleteSuggestionsLoading) {
                          return _buildSuggestionsLoading(state.query);
                        }
                        
                        // Show suggestions when loaded
                        if (state is AutocompleteSuggestionsLoaded) {
                          return _buildSuggestions(
                            state.suggestions,
                            recentSearches: state.recentSearches,
                          );
                        }
                        
                        // Show error when suggestions fail to load
                        if (state is AutocompleteSuggestionsError) {
                          return _buildSuggestionsError(state.failure.message);
                        }
                        
                        // Default state - should not happen
                        return _buildEmptyState();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.1),
            colorScheme.background.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button with elegant ripple effect
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onBackground,
                size: 22,
              ),
              onPressed: () => context.pop(),
              tooltip: 'Back',
              splashRadius: 24,
            ),
          ).animate()
            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
            .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(width: 16),
          
          // Title with premium typography
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Recipes',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                  letterSpacing: -0.5,
                ),
              ).animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),
              const SizedBox(height: 2),
              Text(
                'Discover your next culinary adventure',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.7),
                  letterSpacing: 0.1,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 100.ms, curve: Curves.easeOut)
                .slideY(begin: -0.2, end: 0, duration: 600.ms, delay: 100.ms, curve: Curves.easeOut),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search recipes, ingredients, cuisines...',
          hintStyle: TextStyle(
            color: colorScheme.onBackground.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: colorScheme.primary.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1.5,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    onPressed: _clearSearch,
                    splashRadius: 24,
                  ),
                )
              : null,
        ),
        style: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.search,
        onChanged: (query) {
          context.read<SearchBloc>().add(SearchQueryChanged(query));
          setState(() {}); // To update the clear button visibility
        },
        onSubmitted: _onSearchSubmitted,
      ),
    ).animate()
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
  
  Widget _buildFilterPanel(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(SearchThemeRadius.large),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and toggle button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 2),
            child: Row(
            children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
              Text(
                'Quick Filters',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _toggleFilterExpanded,
                icon: AnimatedRotation(
                  turns: _isFilterExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                label: Text(_isFilterExpanded ? 'Less' : 'More'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ),
            ],
            ),
          ).animate()
            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          
          const SizedBox(height: 4),
          
          // Diet filters - now with multi-select
          FilterChipGroup(
            options: _popularDiets,
            multiSelect: true,
            selectedOptions: _filterOptions.diets,
            onMultiSelected: _onDietFiltersChanged,
            scrollable: true,
            iconMap: {
              'Vegetarian': Icons.spa_outlined,
              'Vegan': Icons.eco_outlined,
              'Gluten Free': Icons.grain_outlined,
              'Keto': Icons.local_fire_department_outlined,
              'Low Carb': Icons.monitor_weight_outlined,
            },
          ).animate()
            .fadeIn(duration: 600.ms, delay: 100.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 100.ms, curve: Curves.easeOutCubic),
          
          // Expandable meal type section with buttons
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isFilterExpanded
                ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
          Text(
            'Meal Type',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
          FilterChipGroup(
            options: const ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack', 'Appetizer'],
                        multiSelect: true,
                        selectedOptions: _filterOptions.mealTypes,
                        onMultiSelected: _onMealTypesChanged,
            scrollable: true,
            iconMap: {
              'Breakfast': Icons.wb_sunny_outlined,
              'Lunch': Icons.restaurant_outlined,
              'Dinner': Icons.dinner_dining_outlined,
              'Dessert': Icons.cake_outlined,
              'Snack': Icons.cookie_outlined,
              'Appetizer': Icons.tapas_outlined,
            },
          ),
                      
                      // Filter buttons - only visible when expanded
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                        child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reset Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                    ),
                    elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: colorScheme.background,
                                ).copyWith(
                                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.hovered))
                                        return colorScheme.primary.withOpacity(0.04);
                                      if (states.contains(MaterialState.pressed))
                                        return colorScheme.primary.withOpacity(0.1);
                                      return null;
                                    },
                                  ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openFilterScreen,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('All Filters'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary,
                    elevation: 2,
                                  shadowColor: colorScheme.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SearchThemeRadius.large),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                                ).copyWith(
                                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.hovered))
                                        return Colors.white.withOpacity(0.04);
                                      if (states.contains(MaterialState.pressed))
                                        return Colors.white.withOpacity(0.1);
                                      return null;
                                    },
                                  ),
                  ),
                ),
              ),
            ],
                        ).animate()
                          .fadeIn(duration: 500.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 100.ms, curve: Curves.easeOutCubic),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms)
                : const SizedBox.shrink(),
          ),
          
          // Bottom padding
          SizedBox(height: _isFilterExpanded ? 0 : 12),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
  
  Widget _buildSearchContent({required List<String> recentSearches}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Recent searches section
        if (recentSearches.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Recent Searches'),
          ),
          SliverToBoxAdapter(
            child: _buildRecentSearchesList(recentSearches),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 16),
          ),
        ],
        
        // Trending searches
        SliverToBoxAdapter(
          child: _buildSectionHeader('Trending Now'),
        ),
        SliverToBoxAdapter(
          child: _buildTrendingSearches(),
        ),
        
        // Recommendations based on preferences
        SliverToBoxAdapter(
          child: _buildSectionHeader('Recommended For You'),
        ),
        SliverToBoxAdapter(
          child: _buildRecommendedCategories(),
        ),
        
        // Add bottom padding to avoid overflow
        SliverToBoxAdapter(
          child: SizedBox(height: kBottomNavigationBarHeight + 20),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceVariant.withOpacity(0.2),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .slideX(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
  
  Widget _buildRecentSearchesList(List<String> recentSearches) {
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: recentSearches.length > 3 ? 175 : recentSearches.length * 50.0, // Reduced from 56
          child: Scrollbar(
            controller: _recentSearchesController,
            thumbVisibility: recentSearches.length > 3,
            radius: const Radius.circular(20),
            thickness: 4,
            child: ListView.builder(
              controller: _recentSearchesController,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              physics: recentSearches.length > 3 
                  ? const BouncingScrollPhysics() 
                  : const NeverScrollableScrollPhysics(),
              itemCount: recentSearches.length,
              itemBuilder: (context, index) {
                final item = RecentSearchItem(
                  search: recentSearches[index],
                  onTap: () => _onRecentSearchTapped(recentSearches[index]),
                  onDelete: () => _deleteRecentSearch(recentSearches[index]),
                );
                
                return Animate(
                  effects: [
                    FadeEffect(
                      delay: Duration(milliseconds: 50 * index),
                      duration: const Duration(milliseconds: 400),
                    ),
                    SlideEffect(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                      delay: Duration(milliseconds: 50 * index),
                      duration: const Duration(milliseconds: 400),
                    ),
                  ],
                  child: item,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrendingSearches() {
    return SizedBox(
      height: 135,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, bottom: 12),
        itemCount: _trendingSearches.length,
        itemBuilder: (context, index) {
          return Animate(
            effects: [
              FadeEffect(
                delay: Duration(milliseconds: 50 * index),
                duration: const Duration(milliseconds: 400),
              ),
              SlideEffect(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
                delay: Duration(milliseconds: 50 * index),
                duration: const Duration(milliseconds: 400),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TrendingSearchCard(
                title: _trendingSearches[index],
                imageUrl: FallbackTrendingImages.getImageUrl(_trendingSearches[index]),
                onTap: () => _onTrendingSearchTapped(_trendingSearches[index]),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecommendedCategories() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0, // Make them square
        ),
        itemCount: _recommendedCategories.length,
        itemBuilder: (context, index) {
          final category = _recommendedCategories[index];
          final gradientColors = CategoryColors.getGradientColors(context, index);
          
          return Animate(
            effects: [
              FadeEffect(
                delay: Duration(milliseconds: 30 * index),
                duration: const Duration(milliseconds: 500),
              ),
              ScaleEffect(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                delay: Duration(milliseconds: 30 * index),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              ),
            ],
            child: CategoryCard(
              title: category['title'],
              icon: category['icon'],
              onTap: () => _onTrendingSearchTapped(category['title']),
              backgroundColor: gradientColors[1],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions, {required List<String> recentSearches}) {
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No suggestions found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildSectionHeader('Suggestions'),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = SearchSuggestionItem(
                suggestion: suggestions[index],
                onTap: () => _onSuggestionTapped(suggestions[index]),
              );
              
              return Animate(
                effects: [
                  FadeEffect(
                    delay: Duration(milliseconds: 30 * index),
                    duration: const Duration(milliseconds: 300),
                  ),
                  SlideEffect(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                    delay: Duration(milliseconds: 30 * index),
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
                child: item,
              );
            },
            childCount: suggestions.length,
          ),
        ),
        
        // Show recent searches below suggestions if available
        if (recentSearches.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('Recent Searches'),
          ),
          SliverToBoxAdapter(
            child: _buildRecentSearchesList(recentSearches),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionsLoading(String query) {
    return const SearchSuggestionShimmer();
  }

  Widget _buildSuggestionsError(String errorMessage) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SearchBloc>().add(SearchQueryChanged(_searchController.text));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              foregroundColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.primary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SearchThemeRadius.large),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 64,
              color: colorScheme.primary,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 800.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Discover Your Next Recipe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ).animate()
            .fadeIn(duration: 800.ms, delay: 200.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Search by recipe name, ingredient, cuisine, or diet type',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ).animate()
            .fadeIn(duration: 800.ms, delay: 300.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
} 