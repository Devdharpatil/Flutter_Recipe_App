import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget that displays recipe meta information like cook time, servings, etc.
class RecipeMetaInfo extends StatelessWidget {
  final int readyInMinutes;
  final int servings;
  final bool healthy;
  final bool sustainable;
  final int? calories;
  
  const RecipeMetaInfo({
    super.key,
    required this.readyInMinutes,
    required this.servings,
    required this.healthy,
    required this.sustainable,
    this.calories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            context,
            Icons.timer,
            '$readyInMinutes min',
            'Cooking Time',
          ),
          _buildDivider(),
          _buildInfoItem(
            context,
            Icons.restaurant,
            '$servings',
            'Servings',
          ),
          if (calories != null) ...[
            _buildDivider(),
            _buildInfoItem(
              context,
              Icons.local_fire_department,
              '$calories',
              'Calories',
              color: Colors.orange.shade700,
            ),
          ],
          if (healthy || sustainable) _buildDivider(),
          if (healthy)
            _buildInfoItem(
              context,
              Icons.favorite,
              'Healthy',
              '',
              color: AppColors.success,
            ),
          if (sustainable)
            _buildInfoItem(
              context,
              Icons.eco,
              'Eco',
              '',
              color: AppColors.success,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(
      height: 40,
      child: VerticalDivider(
        thickness: 1,
        color: Colors.black12,
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color ?? theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
} 