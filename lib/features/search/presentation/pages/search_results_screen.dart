import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../domain/entities/filter_options.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/results_loading_grid.dart';
import '../../../home_discovery/presentation/widgets/loading_recipe_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  
  const SearchResultsScreen({
    super.key,
    required this.query,
  });
  
  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;
  
  @override
  void initState() {
    super.initState();
    
    // Trigger search when screen opens
    context.read<SearchBloc>().add(SearchSubmitted(query: widget.query));
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(const LoadMoreResults());
    }
  }
  
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when within 80% of the end
    return currentScroll >= (maxScroll * 0.8);
  }
  
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }
  
  void _openFilterScreen() {
    context.push('/search_filter');
  }
  
  void _onRetry(String query, FilterOptions? filterOptions) {
    context.read<SearchBloc>().add(SearchSubmitted(
      query: query,
      filterOptions: filterOptions,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilterScreen,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchResultsLoading) {
            return _buildLoadingState();
          }
          
          if (state is SearchResultsEmpty) {
            return _buildEmptyState(state.query, state.filterOptions);
          }
          
          if (state is SearchResultsError) {
            return _buildErrorState(state.query, state.failure.message, state.filterOptions);
          }
          
          if (state is SearchResultsLoaded) {
            return _buildLoadedState(state);
          }
          
          // Default state - should not happen
          return const Center(
            child: Text('No search results available'),
          );
        },
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return _isGridView
        ? const ResultsLoadingGrid()
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (_, __) => const LoadingRecipeCard(isHorizontal: true),
            ),
          );
  }
  
  Widget _buildEmptyState(String query, FilterOptions? filterOptions) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any recipes matching "$query"',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or adjust your filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _openFilterScreen,
                  icon: const Icon(Icons.tune),
                  label: const Text('Adjust Filters'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _onRetry(query, filterOptions),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(String query, String error, FilterOptions? filterOptions) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading results',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _onRetry(query, filterOptions),
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
  
  Widget _buildLoadedState(SearchResultsLoaded state) {
    return Column(
      children: [
        if (state.totalResults > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Text(
                  'Found ${state.totalResults} recipes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (state.filterOptions != null && !state.filterOptions!.isEmpty)
                  Row(
                    children: [
                      const Icon(Icons.filter_list, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Filters applied',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        
        Expanded(
          child: _isGridView
              ? _buildGridView(state)
              : _buildListView(state),
        ),
        
        // Show load more error if exists
        if (state.loadMoreFailure != null && !state.hasReachedMax)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load more recipes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => context.read<SearchBloc>().add(const LoadMoreResults()),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildGridView(SearchResultsLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SearchBloc>().add(SearchSubmitted(
          query: state.query,
          filterOptions: state.filterOptions,
        ));
      },
      child: GridView.builder(
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
              // TODO: Navigate to recipe detail
              context.push('/recipe/${recipe.id}');
            },
            onFavoriteToggle: (isFavorite) {
              // TODO: Toggle favorite status
            },
          );
        },
      ),
    );
  }
  
  Widget _buildListView(SearchResultsLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SearchBloc>().add(SearchSubmitted(
          query: state.query,
          filterOptions: state.filterOptions,
        ));
      },
      child: ListView.separated(
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
              // TODO: Navigate to recipe detail
              context.push('/recipe/${recipe.id}');
            },
            onFavoriteToggle: (isFavorite) {
              // TODO: Toggle favorite status
            },
          );
        },
      ),
    );
  }
} 