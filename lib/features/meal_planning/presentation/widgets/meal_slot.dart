import 'package:flutter/material.dart';
import '../../domain/entities/meal_plan.dart';

class MealSlot extends StatelessWidget {
  final DateTime date;
  final MealType mealType;
  final VoidCallback onTap;
  
  const MealSlot({
    super.key,
    required this.date,
    required this.mealType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Get the color based on meal type
    final mealColor = _getMealTypeColor(mealType);
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Meal type icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: mealColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    mealType.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add ${mealType.displayName}',
                      style: textTheme.titleMedium?.copyWith(
                        color: mealColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMealTypeDescription(mealType),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Add button - with plus icon
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mealColor.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: mealColor,
                  ),
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getMealTypeDescription(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Start your day with energy and nutrition';
      case MealType.lunch:
        return 'Refuel your day with a satisfying midday meal';
      case MealType.dinner:
        return 'Enjoy a delicious and fulfilling evening meal';
      case MealType.snack:
        return 'Grab a quick bite to keep you going';
    }
  }
} 