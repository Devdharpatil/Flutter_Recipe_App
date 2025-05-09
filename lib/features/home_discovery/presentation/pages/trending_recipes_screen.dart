import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/recipe_card.dart';
import '../../../user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../../user_favorites/presentation/bloc/user_favorites_event.dart';
import '../bloc/home_bloc.dart';
import '../widgets/loading_recipe_card.dart';

class TrendingRecipesScreen extends StatefulWidget {
  const TrendingRecipesScreen({Key? key}) : super(key: key);

  @override
  State<TrendingRecipesScreen> createState() => _TrendingRecipesScreenState();
}

class _TrendingRecipesScreenState extends State<TrendingRecipesScreen> {
  @override
  void initState() {
    super.initState();
    // If the state hasn't been loaded yet, load it
    final homeState = context.read<HomeBloc>().state;
    if (homeState is! HomeLoaded) {
      context.read<HomeBloc>().add(const LoadHomeData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Recipes'),
        elevation: 0,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return _buildLoadingView();
          }
          
          if (state is HomeLoaded) {
            if (!state.hasTrendingRecipes) {
              if (state.hasTrendingError) {
                return _buildErrorView(state);
              }
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No trending recipes available',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeData());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: state.trendingRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = state.trendingRecipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    isInGrid: true,
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
          
          if (state is HomeError) {
            return _buildErrorView(state);
          }
          
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const LoadingRecipeCard();
      },
    );
  }

  Widget _buildErrorView(HomeState state) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final message = state is HomeLoaded 
        ? state.trendingFailure?.message ?? 'Unknown error'
        : (state is HomeError ? state.message : 'Unknown error');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load trending recipes',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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
      ),
    );
  }
} 