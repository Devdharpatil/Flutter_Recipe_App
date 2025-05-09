import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/meal_plan.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_bloc.dart';
import '../../../../features/user_favorites/presentation/bloc/user_favorites_state.dart';
import '../bloc/meal_plan_bloc.dart';
import '../bloc/meal_plan_event.dart';
import '../../../../core/widgets/animated_heart_button.dart';

/// A beautifully designed compact meal card that adapts to any screen size
class CompactMealCard extends StatelessWidget {
  final MealPlan meal;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(bool) onFavoriteToggle;
  final void Function(MealPlan) onUpdate;
  final bool isFavorite;
  
  const CompactMealCard({
    super.key,
    required this.meal, 
    required this.onTap,
    required this.onDelete,
    required this.onFavoriteToggle,
    required this.onUpdate,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Recipe tags based on the dish type
    // Normally these would come from the actual recipe model
    // For demonstration, we'll generate sample tags based on meal type
    final List<String> recipeTags = _getRecipeTags(meal.mealType);
    
    // Define consistent text sizes
    const double titleFontSize = 17.5;
    const double smallTextFontSize = 13.0;
    
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          // Distant soft shadow for ambient occlusion - increased
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          // Mid-distance sharper shadow - increased
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 10,
            spreadRadius: -1,
            offset: const Offset(0, 3),
          ),
          // Close, sharp shadow for crisp edge - increased
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Card(
        elevation: 0, 
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade100,
                Colors.grey.shade200.withOpacity(0.5),
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 0.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image - fixed width
                Hero(
                  tag: 'meal_image_${meal.id}',
                  child: SizedBox(
                    width: 120, // Reduced width to avoid overflow
                    height: 120, // Fixed height following the design
                    child: CachedNetworkImage(
                      imageUrl: meal.recipeImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceVariant,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                
                // Recipe details - takes remaining width
                Expanded(
                  child: SizedBox(
                    height: 120, // Match image height
                    child: Stack(
                      children: [
                        // Recipe content - entire area except the favorite icon
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: Recipe title in a single line with ellipsis
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 30), // Space for heart icon
                                      child: Text(
                                        meal.recipeTitle,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: titleFontSize,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 6),
                              
                              // Row 2: Recipe tags in a single line
                              SizedBox(
                                height: 26, // Increased for larger tags
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recipeTags.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, 
                                        vertical: 3
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTagColor(recipeTags[index], colorScheme).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Text(
                                        recipeTags[index],
                                        style: TextStyle(
                                          fontSize: smallTextFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: _getTagColor(recipeTags[index], colorScheme),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Row 3: Meal info indicators - at bottom with smaller font
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4, right: 70), // Space for action buttons
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Time
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 18, // Increased from 16
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '25 min',
                                      style: TextStyle(
                                        fontSize: smallTextFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface.withOpacity(0.9), // Increased opacity
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12), // Increased spacing
                                    
                                    // Calories
                                    Icon(
                                      Icons.whatshot_rounded,
                                      size: 18, // Increased from 16
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '320 cal',
                                      style: TextStyle(
                                        fontSize: smallTextFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface.withOpacity(0.9), // Increased opacity
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12), // Increased spacing
                                    
                                    // People/Servings
                                    Icon(
                                      Icons.people,
                                      size: 18, // Increased from 16
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${meal.servings}',
                                      style: TextStyle(
                                        fontSize: smallTextFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface.withOpacity(0.9), // Increased opacity
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Action buttons positioned at the bottom right
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Row(
                            children: [
                              // Edit button with proper styling but no animation
                              EditIconButton(
                                colorScheme: colorScheme,
                                onTap: () => _showEditDialog(context),
                              ),
                              
                              const SizedBox(width: 6),
                              
                              // Delete button with a stronger shake animation
                              DeleteIconButton(
                                colorScheme: colorScheme,
                                onTap: () => _showDeleteDialog(context),
                              ),
                            ],
                          ),
                        ),
                        
                        // Favorite button positioned at the extreme top right corner
                        Positioned(
                          top: 6,
                          right: 6,
                          child: BlocBuilder<UserFavoritesBloc, UserFavoritesState>(
                            builder: (context, state) {
                              // Determine if the recipe is in favorites from UserFavoritesBloc
                              bool isInFavorites = false;
                              
                              if (state is FavoritesLoaded) {
                                isInFavorites = state.favoriteRecipeIds.contains(meal.recipeId);
                              }
                              
                              // Use the favorite status from UserFavoritesBloc which is the source of truth
                              final isFavoriteNow = isInFavorites;
                              
                              return AnimatedHeartButton(
                                isFavorite: isFavoriteNow,
                                onToggle: () {
                                  onFavoriteToggle(!isFavoriteNow);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  List<String> _getRecipeTags(MealType type) {
    // These would normally come from the recipe data
    // For now, we'll generate sample tags based on meal type
    switch (type) {
      case MealType.breakfast:
        return ['Quick', 'Protein', 'Healthy'];
      case MealType.lunch:
        return ['Savory', 'Low Carb', 'High Protein'];
      case MealType.dinner:
        return ['Balanced', 'Family', 'Comfort'];
      case MealType.snack:
        return ['Light', 'Energizing', 'Sweet'];
    }
  }
  
  Color _getTagColor(String tag, ColorScheme colorScheme) {
    // Create a consistent color based on the tag text
    switch (tag.toLowerCase()) {
      case 'quick':
      case 'fast':
        return Colors.blue;
      case 'protein':
      case 'high protein':
        return Colors.red.shade700;
      case 'healthy':
      case 'light':
        return Colors.green;
      case 'savory':
      case 'balanced':
        return Colors.orange;
      case 'low carb':
        return Colors.purple;
      case 'comfort':
      case 'family':
        return Colors.brown;
      case 'sweet':
      case 'energizing':
        return Colors.amber.shade800;
      default:
        return colorScheme.primary;
    }
  }
  
  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.blue;
      case MealType.snack:
        return Colors.purple;
    }
  }
  
  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.restaurant;
      case MealType.dinner:
        return Icons.soup_kitchen;
      case MealType.snack:
        return Icons.apple;
    }
  }
  
  void _showEditDialog(BuildContext context) {
    // Show calendar picker to reschedule the meal
    showDatePicker(
      context: context,
      initialDate: meal.date, // Current meal date
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate != null && pickedDate != meal.date) {
        // Only proceed if a different date was selected
        
        // Create a rescheduled meal plan using the reschedule method to track original date
        final rescheduledMeal = meal.reschedule(pickedDate);
        
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reschedule Meal'),
            content: Text(
              'Reschedule "${meal.recipeTitle}" to ${_formatDate(pickedDate)}?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  
                  // Call the onUpdate callback with the rescheduled meal
                  onUpdate(rescheduledMeal);
                  
                  // Show a snackbar to confirm the action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Meal rescheduled to ${_formatDate(pickedDate)}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Reschedule'),
              ),
            ],
          ),
        );
      }
    });
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  void _showDeleteDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text(
          'Are you sure you want to remove "${meal.recipeTitle}" from your meal plan?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Call the passed onDelete callback which will trigger the MealPlanBloc
              onDelete();
              
              // Show a snackbar to confirm the action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Meal removed from plan'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit icon button with proper styling and a subtle animation
class EditIconButton extends StatefulWidget {
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  
  const EditIconButton({
    Key? key,
    required this.colorScheme,
    required this.onTap,
  }) : super(key: key);

  @override
  State<EditIconButton> createState() => _EditIconButtonState();
}

class _EditIconButtonState extends State<EditIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.85, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFE0F7FA).withOpacity(0.8)
                : const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.edit_rounded,
              size: 20,
              color: const Color(0xFF00838F),
            ),
          ),
        ),
      ),
    );
  }
}

/// Delete icon button with a stronger shake animation
class DeleteIconButton extends StatefulWidget {
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  
  const DeleteIconButton({
    Key? key,
    required this.colorScheme,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DeleteIconButton> createState() => _DeleteIconButtonState();
}

class _DeleteIconButtonState extends State<DeleteIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // More dramatic shake values with faster movement
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -0.2), weight: 16),
      TweenSequenceItem(tween: Tween<double>(begin: -0.2, end: 0.2), weight: 17),
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: -0.2), weight: 17),
      TweenSequenceItem(tween: Tween<double>(begin: -0.2, end: 0.15), weight: 17),
      TweenSequenceItem(tween: Tween<double>(begin: 0.15, end: -0.1), weight: 17),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.0), weight: 16),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _isPressed
              ? const Color(0xFFFCE4EC).withOpacity(0.8)
              : const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _shakeAnimation.value,
              child: child,
            );
          },
          child: Center(
            child: Icon(
              Icons.delete_rounded,
              size: 20,
              color: const Color(0xFFC2185B),
            ),
          ),
        ),
      ),
    );
  }
} 