import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/recipe_detail.dart';

/// Widget that displays a single ingredient in the recipe detail view
class IngredientListItem extends StatelessWidget {
  /// The ingredient to display
  final Ingredient ingredient;
  
  /// Function to call when the ingredient is tapped
  final VoidCallback? onTap;
  
  /// Function to call when the substitutes button is tapped
  final VoidCallback? onSubstitutesTap;
  
  /// Whether the ingredient is checked in a shopping list
  final bool isChecked;
  
  /// Function to call when the checkbox is toggled
  final ValueChanged<bool>? onCheckChanged;
  
  /// Whether to show a checkbox
  final bool showCheckbox;

  const IngredientListItem({
    super.key,
    required this.ingredient,
    this.onTap,
    this.onSubstitutesTap,
    this.isChecked = false,
    this.onCheckChanged,
    this.showCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ingredient.image != null)
              _buildIngredientImage(ingredient.image!, theme),
            if (ingredient.image == null)
              _buildIngredientPlaceholder(theme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                    '${ingredient.amount} ${ingredient.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (ingredient.aisle != null && ingredient.aisle!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ingredient.aisle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                    ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (showCheckbox) ...[
              const SizedBox(width: 8),
              Checkbox(
                value: isChecked,
                onChanged: onCheckChanged != null 
                    ? (value) => onCheckChanged!(value ?? false)
                    : null,
              ),
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubstitutesButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      onPressed: onSubstitutesTap,
      icon: Icon(
        Icons.swap_horiz,
        size: 16,
        color: theme.colorScheme.onSecondaryContainer,
      ),
      label: Text(
        'Substitutes',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: const Size(0, 32),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildIngredientImage(String imageUrl, ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
            color: theme.colorScheme.surface,
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
          errorWidget: (context, url, error) => _buildIngredientPlaceholder(theme),
        ),
      ),
    );
  }
  
  Widget _buildIngredientPlaceholder(ThemeData theme) {
    return Container(
          width: 50,
          height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }
} 