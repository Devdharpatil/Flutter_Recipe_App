import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../recipe_detail/domain/entities/recipe_detail.dart';
import 'step_timer_widget.dart';

class CookingStepCard extends StatelessWidget {
  final InstructionStep step;
  final int stepNumber;
  final int totalSteps;
  final bool isTimerActive;
  final int? timerRemainingSeconds;
  final VoidCallback? onStartTimer;
  final VoidCallback? onPauseTimer;
  final VoidCallback? onResumeTimer;
  final VoidCallback? onResetTimer;
  
  const CookingStepCard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    this.isTimerActive = false,
    this.timerRemainingSeconds,
    this.onStartTimer,
    this.onPauseTimer,
    this.onResumeTimer,
    this.onResetTimer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Try to extract timing information from the step text
    final timerDuration = _extractTimingFromText(step.step);
    
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              const SizedBox(height: 16),
          // Step indicator
          _buildStepIndicator(context),
          const SizedBox(height: 32),
          
          // Step instruction
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
            step.step,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontSize: 18,
                  ),
            ),
          ),
              const SizedBox(height: 24),
          
          // Timer (if applicable)
          if (timerDuration != null || timerRemainingSeconds != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: StepTimerWidget(
                duration: timerDuration,
                isActive: isTimerActive,
                remainingSeconds: timerRemainingSeconds,
                onStart: onStartTimer,
                onPause: onPauseTimer,
                onResume: onResumeTimer,
                onReset: onResetTimer,
              ),
            ),
          
          // Ingredients used in this step
          if (step.ingredients.isNotEmpty)
            _buildIngredientsSection(context),
          
          // Equipment used in this step
          if (step.equipment.isNotEmpty)
            _buildEquipmentSection(context),
                
              // Add extra space at bottom to prevent overflow
              const SizedBox(height: 100),
        ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Step $stepNumber of $totalSteps',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIngredientsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
        Text(
          'Ingredients for this step:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
                ),
              ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: step.ingredients.map((ingredient) {
            return _buildReferenceChip(
              context,
              ingredient.name,
              ingredient.image,
              Icons.restaurant,
            );
          }).toList(),
        ),
      ],
        ),
      ),
    );
  }
  
  Widget _buildEquipmentSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
              Row(
                children: [
                  Icon(
                    Icons.kitchen,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
        Text(
          'Equipment needed:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
                  ),
                ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: step.equipment.map((equipment) {
            return _buildReferenceChip(
              context,
              equipment.name,
              equipment.image,
              Icons.kitchen,
            );
          }).toList(),
        ),
      ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReferenceChip(
    BuildContext context, 
    String name, 
    String? imageUrl, 
    IconData fallbackIcon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                placeholder: (_, __) => Icon(
                  fallbackIcon,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                errorWidget: (_, __, ___) => Icon(
                  fallbackIcon,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Icon(
              fallbackIcon,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
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
    );
  }
  
  // Helper method to extract timing information from text
  int? _extractTimingFromText(String text) {
    // Common patterns for cooking times
    final regexPatterns = [
      RegExp(r'(\d+)[\s-]*(minute|min)s?', caseSensitive: false),
      RegExp(r'(\d+)[\s-]*(hour|hr)s?', caseSensitive: false),
      RegExp(r'for[\s-]*(\d+)[\s-]*(minute|min)s?', caseSensitive: false),
      RegExp(r'for[\s-]*(\d+)[\s-]*(hour|hr)s?', caseSensitive: false),
    ];
    
    for (final regex in regexPatterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = int.tryParse(match.group(1) ?? '');
        final unit = match.group(2)?.toLowerCase();
        
        if (value != null) {
          // Convert to seconds
          if (unit == 'hour' || unit == 'hr') {
            return value * 60 * 60; // hours to seconds
          } else {
            return value * 60; // minutes to seconds
          }
        }
      }
    }
    
    return null;
  }
} 