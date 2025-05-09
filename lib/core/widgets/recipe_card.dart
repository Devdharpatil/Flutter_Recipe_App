import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../features/user_favorites/presentation/bloc/user_favorites_event.dart';
import '../../features/user_favorites/presentation/bloc/user_favorites_state.dart';
import 'animated_heart_button.dart';

class RecipeCard extends StatelessWidget {
  final dynamic recipe; // Can accept different recipe entity types
  final VoidCallback onTap;
  final Function(bool)? onFavoriteToggle;
  final bool isInGrid;
  final bool isHorizontal;
  final bool showFavoriteButton;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteToggle,
    this.isInGrid = false,
    this.isHorizontal = false,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Safely extract common properties
    final int recipeId = recipe.id ?? 0;
    final String title = recipe.title ?? 'Recipe';
    final String imageUrl = recipe.image ?? '';
    final int? readyInMinutes = recipe.readyInMinutes;
    
    // Get dish type if available
    final List<String> dishTypes = [];
    if (recipe.dishTypes != null && recipe.dishTypes.isNotEmpty) {
      if (recipe.dishTypes is List) {
        dishTypes.addAll(List<String>.from(recipe.dishTypes));
      }
    }

    // Horizontal layout (for search results or compact listings)
    if (isHorizontal) {
      return Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 120,
            child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                // Left side - Image
                SizedBox(
                  width: 120, 
                  height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                        imageUrl: imageUrl,
                      fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceVariant.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceVariant.withOpacity(0.2),
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ),
                    // Gradient overlay for better text contrast
                    Positioned.fill(
                        child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                                Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.3),
                            ],
                            ),
                          ),
                        ),
                      ),
                      // Time indicator in bottom left
                      if (readyInMinutes != null)
                      Positioned(
                          bottom: 8,
                        left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$readyInMinutes min',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                      ),
                  ],
                ),
              ),
              ),
          ],
        ),
                ),
                
                // Right side - Content
        Expanded(
          child: Padding(
                    padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                          title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                        
                        const SizedBox(height: 4),
                        
                        // Dish type
                        if (dishTypes.isNotEmpty)
                          Text(
                            _capitalizeFirstLetter(dishTypes.first),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        
                const Spacer(),
                        
                        // Bottom row
                Row(
                  children: [
                            // Servings if available
                            if (recipe.servings != null) ...[
                      Icon(
                                Icons.people_outline,
                                size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                                '${recipe.servings}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                              const SizedBox(width: 12),
                    ],
                            
                            // Diet tag if available
                            if (recipe.diets != null && recipe.diets is List && (recipe.diets as List).isNotEmpty)
                              _buildDietTag(context, (recipe.diets as List).first.toString(), small: true),
                            
                    const Spacer(),
                            
                            // Favorite button
                            if (showFavoriteButton)
                              _buildFavoriteIcon(context, recipeId),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Grid/Vertical card - new squarish design
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 0.9, // Slightly taller than square for better aesthetics
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section - takes up approximately 2/3 of card
              Expanded(
                flex: 7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceVariant.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceVariant.withOpacity(0.2),
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                ),
                    
                    // Gradient overlay for better text contrast
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Diet tag - top left
                    if (recipe.diets != null && recipe.diets is List && (recipe.diets as List).isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildDietTag(
                          context, 
                          (recipe.diets as List).first.toString(),
                        ),
                      ),
                    
                    // Favorite button - top right with semi-transparency
                    if (showFavoriteButton)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: _buildFavoriteIcon(context, recipeId, transparent: true),
                        ),
                      ),
                    
                    // Time indicator - bottom left
                    if (readyInMinutes != null)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$readyInMinutes min',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                            fontWeight: FontWeight.w500,
                                ),
                  ),
              ],
            ),
          ),
        ),
                      
                    // Servings indicator - bottom right
                    if (recipe.servings != null)
                      Positioned(
                        bottom: 12,
                        right: 12,
          child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                          children: [
                              const Icon(
                                Icons.people_outline,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.servings}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                                    ),
                                  ),
                                ),
                  ],
                              ),
                            ),
              
              // Content section - takes up approximately 1/3 of card
                            Expanded(
                flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                      // Title
                                    Text(
                        title,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                          fontSize: isInGrid ? 14 : 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                      
                      const SizedBox(height: 4),
                      
                      // Dish type with dot indicator
                      if (dishTypes.isNotEmpty)
                                    Row(
                                      children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                                          ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _capitalizeFirstLetter(dishTypes.first),
                                            style: textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                        
                      // If we have health score, show it as a bar
                      if (recipe.healthScore != null && recipe.healthScore > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: _getHealthScoreColor(recipe.healthScore),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: recipe.healthScore / 100,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  color: _getHealthScoreColor(recipe.healthScore),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                      ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // Favorite button with transparency option
  Widget _buildFavoriteIcon(BuildContext context, int recipeId, {bool transparent = false}) {
    return BlocBuilder<UserFavoritesBloc, UserFavoritesState>(
      builder: (context, state) {
        bool isFavorite = false;
        
        if (state is FavoritesLoaded) {
          isFavorite = state.favoriteRecipeIds.contains(recipeId);
        }
        
        return AnimatedHeartButton(
          isFavorite: isFavorite,
          onToggle: () {
            if (onFavoriteToggle != null) {
              HapticFeedback.lightImpact();
              onFavoriteToggle!(!isFavorite);
            }
          },
          width: 36, 
          height: 36,
          iconSize: 20,
          heartColor: transparent ? Colors.white.withOpacity(0.9) : Colors.red,
          showBackground: !transparent, // No background when transparent=true
        );
      },
    );
  }

  // Diet tag builder with size option
  Widget _buildDietTag(BuildContext context, String diet, {bool small = false}) {
    if (diet.isEmpty) return const SizedBox.shrink();
    
    final textTheme = Theme.of(context).textTheme;
    
    // Map diet tags to friendly display names and colors
    final Map<String, Color> dietColors = {
      'gluten free': Colors.purple,
      'dairy free': Colors.blue,
      'vegetarian': Colors.green,
      'vegan': Colors.teal,
      'pescatarian': Colors.lightBlue,
      'paleo': Colors.amber,
      'primal': Colors.orange,
      'whole30': Colors.deepOrange,
      'lacto ovo vegetarian': Colors.lightGreen,
    };
    
    final String displayName = diet.split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
    
    final Color tagColor = dietColors[diet.toLowerCase()] ?? Colors.grey;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10, 
        vertical: small ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(small ? 12 : 20),
      ),
      child: Text(
        displayName,
        style: (small ? textTheme.labelSmall : textTheme.labelMedium)?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: small ? 10 : 12,
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  // Get color based on health score
  Color _getHealthScoreColor(num score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.amber;
    if (score >= 20) return Colors.orange;
    return Colors.red;
  }
} 