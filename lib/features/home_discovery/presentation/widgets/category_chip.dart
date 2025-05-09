import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      avatar: _getCategoryIcon(label, isSelected, colorScheme),
      backgroundColor: isSelected
          ? colorScheme.primary 
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
              ? Colors.transparent 
              : colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      elevation: isSelected ? 3 : 0,
      shadowColor: colorScheme.shadow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: onTap,
    );
  }
  
  Widget? _getCategoryIcon(String category, bool isSelected, ColorScheme colorScheme) {
    IconData iconData;
    
    switch (category.toLowerCase()) {
      case 'breakfast':
        iconData = Icons.breakfast_dining;
        break;
      case 'lunch':
        iconData = Icons.lunch_dining;
        break;
      case 'dinner':
        iconData = Icons.dinner_dining;
        break;
      case 'dessert':
        iconData = Icons.icecream;
        break;
      case 'appetizer':
        iconData = Icons.tapas;
        break;
      case 'salad':
        iconData = Icons.eco;
        break;
      case 'soup':
        iconData = Icons.soup_kitchen;
        break;
      case 'snack':
        iconData = Icons.cookie;
        break;
      case 'beverage':
        iconData = Icons.local_drink;
        break;
      case 'vegan':
        iconData = Icons.grass;
        break;
      case 'vegetarian':
        iconData = Icons.spa;
        break;
      case 'gluten-free':
        iconData = Icons.do_not_disturb;
        break;
      default:
        iconData = Icons.restaurant;
    }
    
    return Icon(
      iconData,
      size: 16,
      color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
    );
  }
} 