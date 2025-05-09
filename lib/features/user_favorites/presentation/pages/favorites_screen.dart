import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/app_header.dart';
import '../bloc/user_favorites_bloc.dart';
import '../bloc/user_favorites_event.dart';
import '../bloc/user_favorites_state.dart';
import '../widgets/favorites_empty_state.dart';
import '../widgets/favorites_recipe_grid.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: BlocConsumer<UserFavoritesBloc, UserFavoritesState>(
          listener: (context, state) {
            // Handle transient states for snackbar messages
            if (state is FavoritesActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is FavoritesActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          // Listen only to transient states
          listenWhen: (previous, current) =>
              current is FavoritesActionSuccess || current is FavoritesActionFailure,
          buildWhen: (previous, current) =>
              current is! FavoritesActionSuccess && current is! FavoritesActionFailure,
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium consistent header matching Settings screen
                AppHeader(
                  title: 'My Favorites',
                  subtitle: 'Your saved recipes',
                  isPinned: true,
                  expandedHeight: 100, // Match Settings screen exactly
                  backgroundColor: colorScheme.background, // Ensure proper background color
                  actions: [
                    // Search action with consistent styling
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.onBackground,
                          size: 24,
                        ),
                        onPressed: () {
                          context.push('/search');
                        },
                      ),
                    ),
                  ],
                ),
                
                // Content based on state
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: _buildContent(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, UserFavoritesState state) {
    // On first build, trigger loading favorite IDs
    if (state is FavoritesInitial) {
      context.read<UserFavoritesBloc>().add(const LoadFavorites());
      return const LoadingIndicator();
    }

    // Loading state
    if (state is FavoritesLoading) {
      return const LoadingIndicator();
    }

    // Error state
    if (state is FavoritesError) {
      return ErrorView(
        message: state.failure.message,
        onRetry: () => context.read<UserFavoritesBloc>().add(const LoadFavorites()),
      );
    }

    // Success state
    if (state is FavoritesLoaded) {
      if (state.favoriteRecipeIds.isEmpty) {
        // Empty state
        return const FavoritesEmptyState();
      }

      // Show favorites grid
      return FavoritesRecipeGrid(favoriteIds: state.favoriteRecipeIds);
    }

    // Fallback for any unhandled states
    return const Center(
      child: Text('Something went wrong. Please try again.'),
    );
  }
} 