import 'package:flutter/material.dart';

class CategoryGridCard extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor(category, colorScheme).withOpacity(0.7),
                  _getCategoryColor(category, colorScheme),
                ],
              ),
            ),
          ),
          // Content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'dessert':
        return Icons.icecream;
      case 'appetizer':
        return Icons.tapas;
      case 'salad':
        return Icons.eco;
      case 'soup':
        return Icons.soup_kitchen;
      case 'snack':
        return Icons.cookie;
      case 'beverage':
        return Icons.local_drink;
      case 'vegan':
        return Icons.grass;
      case 'vegetarian':
        return Icons.spa;
      case 'gluten-free':
        return Icons.do_not_disturb;
      default:
        return Icons.restaurant;
    }
  }
  
  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.amber.shade700;
      case 'dinner':
        return Colors.indigo;
      case 'dessert':
        return Colors.pink;
      case 'appetizer':
        return Colors.teal;
      case 'salad':
        return Colors.green;
      case 'soup':
        return Colors.brown;
      case 'snack':
        return Colors.deepOrange;
      case 'beverage':
        return Colors.blue;
      case 'vegan':
        return Colors.lightGreen;
      case 'vegetarian':
        return Colors.green.shade700;
      case 'gluten-free':
        return Colors.purple;
      default:
        return colorScheme.primary;
    }
  }
} 