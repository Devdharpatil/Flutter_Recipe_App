import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../../recipe_detail/domain/entities/recipe_detail.dart';
import '../../../recipe_detail/domain/usecases/get_recipe_detail_usecase.dart';
import '../bloc/user_favorites_bloc.dart';
import '../bloc/user_favorites_event.dart';

class FavoritesRecipeGrid extends StatefulWidget {
  final Set<int> favoriteIds;

  const FavoritesRecipeGrid({
    super.key,
    required this.favoriteIds,
  });

  @override
  State<FavoritesRecipeGrid> createState() => _FavoritesRecipeGridState();
}

class _FavoritesRecipeGridState extends State<FavoritesRecipeGrid> with SingleTickerProviderStateMixin {
  late Future<List<RecipeDetail>> _recipeDetailsFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadRecipeDetails();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoritesRecipeGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteIds != widget.favoriteIds) {
      _loadRecipeDetails();
    }
  }

  void _loadRecipeDetails() {
    final getRecipeDetail = context.read<GetRecipeDetailUseCase>();
    _recipeDetailsFuture = Future.wait(
      widget.favoriteIds.map((id) async {
        final result = await getRecipeDetail(RecipeParams(recipeId: id));
        return result.fold(
          (failure) => throw Exception(failure.message),
          (recipe) => recipe,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FutureBuilder<List<RecipeDetail>>(
      future: _recipeDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        } else if (snapshot.hasError) {
          return ErrorView(
            message: 'Failed to load recipe details: ${snapshot.error}',
            onRetry: _loadRecipeDetails,
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final recipes = snapshot.data!;
          
          return FadeTransition(
            opacity: _animationController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = index * 0.1;
                        final startAt = delay.clamp(0.0, 0.9);
                        final delayedAnimation = 
                            Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(startAt, 1.0, curve: Curves.easeOutQuint),
                          ),
                        );
                        
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - delayedAnimation.value)),
                          child: Opacity(
                            opacity: delayedAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () => context.push('/recipe/${recipe.id}'),
                        onFavoriteToggle: (isFavorite) {
                          HapticFeedback.lightImpact();
                          context.read<UserFavoritesBloc>().add(
                            ToggleFavorite(
                              recipeId: recipe.id,
                              currentStatus: true,
                            ),
                          );
                        },
                        isInGrid: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
        
        return const Center(child: Text('No recipes found'));
      },
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.favoriteIds.length,
          itemBuilder: (context, index) {
            return _buildShimmerCard();
          },
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainer,
        highlightColor: colorScheme.surfaceContainerHighest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 