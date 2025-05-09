import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'animated_heart_button.dart';

class EnhancedRecipeCard extends StatefulWidget {
  final dynamic recipe;
  final VoidCallback onTap;
  final Function(bool)? onFavoriteToggle;
  final bool isHorizontal;
  final bool showMealPlanButton;

  const EnhancedRecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteToggle,
    this.isHorizontal = false,
    this.showMealPlanButton = true,
  }) : super(key: key);

  @override
  State<EnhancedRecipeCard> createState() => _EnhancedRecipeCardState();
}

class _EnhancedRecipeCardState extends State<EnhancedRecipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _onHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChange(true),
            onExit: (_) => _onHoverChange(false),
            child: widget.isHorizontal 
              ? _buildHorizontalCard(context) 
              : _buildVerticalCard(context),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Extract recipe properties
    final int recipeId = widget.recipe.id ?? 0;
    final String title = widget.recipe.title ?? 'Recipe';
    final String imageUrl = widget.recipe.image ?? '';
    final int? readyInMinutes = widget.recipe.readyInMinutes;
    final int? calories = _extractCalories();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                ? colorScheme.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
              blurRadius: _isHovered ? 12 : 6,
              offset: _isHovered 
                ? const Offset(0, 4)
                : const Offset(0, 2),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with overlay buttons
            Stack(
              children: [
                // Main image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: CachedNetworkImage(
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
                  ),
                ),
                
                // Top right buttons - semi-transparent background
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      // Favorite button
                      AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.9, // Increased opacity
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35), // More visible background
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: AnimatedHeartButton(
                            isFavorite: widget.recipe.isFavorite ?? false,
                            onToggle: () {
                              _handleFavoriteToggle();
                            },
                          ),
                        ),
                      ),
                      if (widget.showMealPlanButton) const SizedBox(width: 8),
                      // Meal plan button (optional)
                      if (widget.showMealPlanButton)
                        AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.9, // Increased opacity
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35), // More visible background
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _handleMealPlanAdd(context);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Recipe info badges (time, calorie, etc.)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time indicator
                      if (readyInMinutes != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7), // More visible background
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
                      
                      // Calories indicator
                      if (calories != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7), // More visible background
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${calories.round()} cal',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Content container - always full width
            Container(
              width: double.infinity, // Make sure it takes full width
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                gradient: _isHovered ? 
                  LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      colorScheme.primary.withOpacity(0.05),
                    ],
                  ) : null,
              ),
              child: Center( // Center the title
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center, // Center align
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Extract recipe properties
    final int recipeId = widget.recipe.id ?? 0;
    final String title = widget.recipe.title ?? 'Recipe';
    final String imageUrl = widget.recipe.image ?? '';
    final int? readyInMinutes = widget.recipe.readyInMinutes;
    final int? calories = _extractCalories();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                ? colorScheme.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered 
                ? const Offset(0, 6)
                : const Offset(0, 2),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with overlay buttons
            Stack(
              children: [
                // Main image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: CachedNetworkImage(
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
                          size: 60,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Top right buttons - semi-transparent background
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      // Favorite button
                      AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.9, // Increased opacity
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4), // More visible background
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AnimatedHeartButton(
                            isFavorite: widget.recipe.isFavorite ?? false,
                            onToggle: () {
                              _handleFavoriteToggle();
                            },
                          ),
                        ),
                      ),
                      if (widget.showMealPlanButton) const SizedBox(width: 10),
                      // Meal plan button (optional)
                      if (widget.showMealPlanButton)
                        AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.9, // Increased opacity
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4), // More visible background
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _handleMealPlanAdd(context);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Recipe info badges (time, calorie, etc.)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time indicator
                      if (readyInMinutes != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7), // More visible background
                            borderRadius: BorderRadius.circular(16),
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
                      
                      // Calories indicator - made more visible
                      if (calories != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7), // More visible background
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${calories.round()} cal',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Content container - full width with centered title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center align content
                children: [
                  // Recipe title
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Center align text
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Tags (for vertical cards only) - improved styling
                  if (widget.recipe.diets != null && widget.recipe.diets!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 28, // Fixed height for one line
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the tags
                          children: List.generate(
                            widget.recipe.diets!.length.clamp(0, 3), // Limit to 3 tags
                            (index) {
                              final diet = widget.recipe.diets![index].toString();
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTagColor(diet),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTagColor(diet).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _capitalizeFirstLetter(diet),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Add some spacing at bottom
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to handle favorite toggle with haptic feedback
  void _handleFavoriteToggle() {
    HapticFeedback.lightImpact();
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!(!(widget.recipe.isFavorite ?? false));
    }
  }
  
  // Helper method to handle meal plan addition
  void _handleMealPlanAdd(BuildContext context) {
    HapticFeedback.lightImpact();
    // Show meal plan dialog (similar to recipe detail page)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddToMealPlanDialog(context),
    );
  }
  
  // Build meal plan dialog
  Widget _buildAddToMealPlanDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add to Meal Plan',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select date and meal type:',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // Date picker would go here
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.primary),
                const SizedBox(width: 16),
                Text(
                  'Today', // placeholder - would be actual date picker
                  style: textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Meal type dropdown would go here
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, color: colorScheme.primary),
                const SizedBox(width: 16),
                Text(
                  'Dinner', // placeholder - would be meal type dropdown
                  style: textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add to meal plan functionality
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to meal plan'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add to Plan',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Get tag color based on diet type
  Color _getTagColor(String dietType) {
    final Map<String, Color> dietColors = {
      'vegetarian': Colors.green.shade600,
      'vegan': Colors.teal.shade700,
      'glutenfree': Colors.amber.shade700,
      'dairyfree': Colors.blue.shade700,
      'lowfodmap': Colors.orange.shade700,
      'whole30': Colors.red.shade700,
      'ketogenic': Colors.purple.shade700,
      'paleo': Colors.brown.shade700,
    };
    
    // Remove spaces and convert to lowercase for matching
    final normalizedType = dietType.toLowerCase().replaceAll(' ', '');
    
    // Return color or default color
    return dietColors[normalizedType] ?? Colors.blueGrey.shade700;
  }
  
  // Helper method to extract calories from nutrition data
  int? _extractCalories() {
    try {
      // Try to access calories from different possible paths in the recipe model
      if (widget.recipe.nutrition != null && 
          widget.recipe.nutrition['nutrients'] != null) {
        // Find calories in nutrients array
        final nutrients = widget.recipe.nutrition['nutrients'] as List;
        final calorieItem = nutrients.firstWhere(
          (nutrient) => nutrient['name'] == 'Calories',
          orElse: () => null,
        );
        if (calorieItem != null) {
          return calorieItem['amount'].round();
        }
      }
      
      // Alternative path if calories are directly on the model
      if (widget.recipe.calories != null) {
        return widget.recipe.calories.round();
      }
      
      // Return null if calories can't be found
      return null;
    } catch (e) {
      // Return null if any error occurs
      return null;
    }
  }

  // Add a helper method to handle the sourceName property safely (no longer used)
  String _getChefName() {
    try {
      // Try to access the sourceName property, return it if it exists
      return widget.recipe.sourceName ?? 'Unknown Chef';
    } catch (e) {
      // If the property doesn't exist or any other error occurs, return a default value
      return 'Chef';
    }
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
} 