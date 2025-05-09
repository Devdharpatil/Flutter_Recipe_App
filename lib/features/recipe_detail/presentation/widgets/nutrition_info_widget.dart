import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/recipe_detail.dart';

/// Widget that displays nutrition information for a recipe
class NutritionInfoWidget extends StatelessWidget {
  final NutritionInfo nutrition;

  const NutritionInfoWidget({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Find the key nutrients
    final calories = _findNutrient(nutrition.nutrients, 'Calories');
    final fat = _findNutrient(nutrition.nutrients, 'Fat');
    final carbs = _findNutrient(nutrition.nutrients, 'Carbohydrates');
    final protein = _findNutrient(nutrition.nutrients, 'Protein');
    final fiber = _findNutrient(nutrition.nutrients, 'Fiber');
    final sugar = _findNutrient(nutrition.nutrients, 'Sugar');
    final sodium = _findNutrient(nutrition.nutrients, 'Sodium');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (calories != null) _buildCalorieHeader(context, calories),
        const SizedBox(height: 16),
        _buildMainNutrientsChart(context, fat, carbs, protein),
        const SizedBox(height: 24),
        _buildNutrientsList(context, [
          if (fat != null) _buildNutrientItem(context, 'Fat', fat, AppColors.fat),
          if (carbs != null) _buildNutrientItem(context, 'Carbs', carbs, AppColors.carbs),
          if (protein != null) _buildNutrientItem(context, 'Protein', protein, AppColors.protein),
          if (fiber != null) _buildNutrientItem(context, 'Fiber', fiber, theme.colorScheme.primary),
          if (sugar != null) _buildNutrientItem(context, 'Sugar', sugar, Colors.pink),
          if (sodium != null) _buildNutrientItem(context, 'Sodium', sodium, Colors.blue),
        ]),
        const SizedBox(height: 16),
        Text(
          'Nutritional values are per serving',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCalorieHeader(BuildContext context, Nutrient calories) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.calories,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            '${calories.amount.toInt()}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'calories',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (calories.percentOfDailyNeeds != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${calories.percentOfDailyNeeds!.toInt()}% Daily',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainNutrientsChart(
    BuildContext context,
    Nutrient? fat,
    Nutrient? carbs,
    Nutrient? protein,
  ) {
    if (fat == null || carbs == null || protein == null) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    final total = fat.amount + carbs.amount + protein.amount;
    
    // Calculate percentages
    final fatPercent = total > 0 ? (fat.amount / total * 100) : 0.0;
    final carbsPercent = total > 0 ? (carbs.amount / total * 100) : 0.0;
    final proteinPercent = total > 0 ? (protein.amount / total * 100) : 0.0;
    
    return Column(
      children: [
        Container(
          height: 20,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: fatPercent.round(),
                child: Container(color: AppColors.fat),
              ),
              Expanded(
                flex: carbsPercent.round(),
                child: Container(color: AppColors.carbs),
              ),
              Expanded(
                flex: proteinPercent.round(),
                child: Container(color: AppColors.protein),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(context, 'Fat', AppColors.fat, '${fatPercent.round()}%'),
            _buildLegendItem(context, 'Carbs', AppColors.carbs, '${carbsPercent.round()}%'),
            _buildLegendItem(context, 'Protein', AppColors.protein, '${proteinPercent.round()}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    String value,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientsList(BuildContext context, List<Widget> children) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children,
    );
  }

  Widget _buildNutrientItem(
    BuildContext context,
    String label,
    Nutrient nutrient,
    Color color,
  ) {
    final theme = Theme.of(context);
    final hasPercentage = nutrient.percentOfDailyNeeds != null;
    
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${nutrient.amount.toStringAsFixed(1)} ${nutrient.unit}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasPercentage)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${nutrient.percentOfDailyNeeds!.round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Nutrient? _findNutrient(List<Nutrient> nutrients, String name) {
    try {
      return nutrients.firstWhere(
        (nutrient) => nutrient.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
} 