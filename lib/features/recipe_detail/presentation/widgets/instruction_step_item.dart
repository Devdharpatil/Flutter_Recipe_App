import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/recipe_detail.dart';

/// Widget that displays a single instruction step in the recipe detail view
class InstructionStepItem extends StatelessWidget {
  /// The instruction step to display
  final InstructionStep step;
  
  /// The number of this step in the sequence
  final int stepNumber;
  
  /// Whether this step is the current active step in cooking mode
  final bool isActive;
  
  /// Whether this step is already completed in cooking mode
  final bool isCompleted;

  const InstructionStepItem({
    super.key,
    required this.step,
    required this.stepNumber,
    this.isActive = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isActive 
                ? theme.colorScheme.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isActive ? 10 : 4,
            offset: const Offset(0, 2),
            spreadRadius: isActive ? 1 : 0,
          ),
        ],
        border: Border.all(
          color: _getBorderColor(theme),
          width: isActive ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          const SizedBox(height: 12),
          Text(
            step.step,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isCompleted
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : theme.colorScheme.onSurface,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
                    height: 1.6,
                    fontSize: 16.5,
                    letterSpacing: 0.15,
                  ),
                ),
                if (step.ingredients.isNotEmpty || step.equipment.isNotEmpty) ...[
                  const SizedBox(height: 20),
            _buildStepReferences(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
                color: isActive
            ? theme.colorScheme.primary.withOpacity(0.1) 
                    : isCompleted
                ? AppColors.success.withOpacity(0.05)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
            ),
          ),
      child: Row(
        children: [
          _buildStepNumberIndicator(theme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        Text(
          'Step $stepNumber',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isCompleted
                ? theme.colorScheme.onSurface.withOpacity(0.6)
                        : isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'CURRENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else if (isCompleted)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
            child: Icon(
                Icons.check,
              color: AppColors.success,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStepNumberIndicator(ThemeData theme) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _getStepNumberColor(theme),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isActive 
                ? theme.colorScheme.primary.withOpacity(0.3) 
                : isCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
      ],
        border: isActive || isCompleted 
            ? Border.all(
                color: isActive 
                    ? theme.colorScheme.primary.withOpacity(0.5) 
                    : AppColors.success.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: isActive
                ? theme.colorScheme.onPrimary
                : isCompleted
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepReferences(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.ingredients.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
          Text(
                  'Ingredients for this step',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          _buildReferencesList(
            context,
            step.ingredients,
            (ref) => ref.image,
            (ref) => ref.name,
            Icons.shopping_basket,
          ),
            if (step.equipment.isNotEmpty)
              const SizedBox(height: 20),
        ],
        if (step.equipment.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.kitchen,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
          Text(
                  'Equipment needed',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          _buildReferencesList(
            context,
            step.equipment,
            (ref) => ref.image,
            (ref) => ref.name,
            Icons.restaurant,
          ),
        ],
      ],
      ),
    );
  }

  Widget _buildReferencesList<T>(
    BuildContext context,
    List<T> items,
    String? Function(T) getImageUrl,
    String Function(T) getName,
    IconData fallbackIcon,
  ) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: items.map((item) {
        final imageUrl = getImageUrl(item);
        final name = getName(item);
        
        return Material(
          color: Colors.transparent,
          child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
          ),
          decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primaryContainer,
                width: 1,
              ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Icon(
                      fallbackIcon,
                      size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          fallbackIcon,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      fallbackIcon,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                ),
                const SizedBox(width: 8),
              Text(
                name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                ),
              ),
            ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (isActive) {
      return theme.colorScheme.surface;
    } else if (isCompleted) {
      return theme.colorScheme.surfaceContainerHighest.withOpacity(0.2);
    }
    return theme.colorScheme.surface;
  }

  Color _getBorderColor(ThemeData theme) {
    if (isActive) {
      return theme.colorScheme.primary;
    } else if (isCompleted) {
      return AppColors.success.withOpacity(0.5);
    }
    return theme.colorScheme.outline.withOpacity(0.2);
  }

  Color _getStepNumberColor(ThemeData theme) {
    if (isActive) {
      return theme.colorScheme.primary;
    } else if (isCompleted) {
      return AppColors.success;
    }
    return theme.colorScheme.surfaceContainerHighest;
  }
} 