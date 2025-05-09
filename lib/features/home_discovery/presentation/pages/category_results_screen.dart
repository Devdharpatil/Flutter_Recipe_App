import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../bloc/category_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/loading_recipe_card.dart';
import '../widgets/grid_loading_recipe_card.dart';

class CategoryResultsScreen extends StatefulWidget {
  final String category;

  const CategoryResultsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryResultsScreen> createState() => _CategoryResultsScreenState();
}

class _CategoryResultsScreenState extends State<CategoryResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategoryRecipes(category: widget.category));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CategoryBloc>().add(const LoadMoreCategoryRecipes());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} Recipes',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryInitial || state is CategoryLoading) {
            return _buildLoadingState(colorScheme);
          }
          
          if (state is CategoryError) {
            return _buildErrorState(state, textTheme, colorScheme);
          }
          
          if (state is CategoryLoaded) {
            if (state.recipes.isEmpty) {
              return _buildEmptyState(textTheme, colorScheme);
            }
            
            return _buildLoadedState(state, colorScheme);
          }
          
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    if (_isGridView) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
          highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: 8, // Show 8 shimmer placeholders
            itemBuilder: (_, __) => const GridLoadingRecipeCard(),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: 8,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (_, __) => const LoadingRecipeCard(isHorizontal: true),
        ),
      );
    }
  }
  
  Widget _buildLoadedState(CategoryLoaded state, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CategoryBloc>().add(LoadCategoryRecipes(
          category: widget.category,
        ));
      },
      child: Column(
        children: [
          Expanded(
            child: _isGridView 
                ? _buildGridView(state, colorScheme)
                : _buildListView(state, colorScheme),
          ),
          if (state.loadMoreError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.errorContainer.withOpacity(0.2),
              child: Column(
                children: [
                  Text(
                    'Error loading more recipes',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.loadMoreError!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.read<CategoryBloc>().add(const LoadMoreCategoryRecipes());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildGridView(CategoryLoaded state, ColorScheme colorScheme) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: state.hasReachedMax
          ? state.recipes.length
          : state.recipes.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.recipes.length) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 2,
            ),
          );
        }
        
        final recipe = state.recipes[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () {
            // Navigate to recipe detail
            context.push('/recipe/${recipe.id}');
          },
          onFavoriteToggle: (isFavorite) {
            // TODO: Toggle favorite status
          },
        );
      },
    );
  }
  
  Widget _buildListView(CategoryLoaded state, ColorScheme colorScheme) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: state.hasReachedMax
          ? state.recipes.length
          : state.recipes.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.recipes.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }
        
        final recipe = state.recipes[index];
        return RecipeCard(
          recipe: recipe,
          isHorizontal: true,
          onTap: () {
            // Navigate to recipe detail
            context.push('/recipe/${recipe.id}');
          },
          onFavoriteToggle: (isFavorite) {
            // TODO: Toggle favorite status
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_meals,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes found',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any ${widget.category} recipes',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoryBloc>().add(LoadCategoryRecipes(
                  category: widget.category,
                ));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(CategoryError state, TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoryBloc>().add(LoadCategoryRecipes(
                  category: widget.category,
                ));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 